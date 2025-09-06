// ContentView.swift
import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    
    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    // A ContentView agora recebe o controller de uma view pai como @ObservedObject
    @ObservedObject var controller: GastoController
    
    // MARK: - Salários
    @State private var salarioMarido: String = ""
    @State private var salarioEsposa: String = ""
    
    // Teclado: controle de foco SwiftUI (sem UIKit)
    private enum FocusedField: Hashable { case salarioMarido, salarioEsposa }
    @FocusState private var focusedField: FocusedField?
    
    // MARK: - Filtro mês/ano
    @State private var mesSelecionado = Calendar.current.component(.month, from: Date())
    @State private var anoSelecionado = Calendar.current.component(.year, from: Date())
    
    // MARK: - Modal para adicionar gasto
    @State private var mostrarAdicionarGasto = false
    
    // MARK: - Gastos filtrados
    var gastosFiltrados: [GastoEntity] {
        controller.filtrarPorMesAno(gastos: controller.gastos, mes: mesSelecionado, ano: anoSelecionado)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Mês e Ano
                    HStack {
                        Picker("Mês", selection: $mesSelecionado) {
                            ForEach(1...12, id: \.self) { Text("\($0)") }
                        }
                        .pickerStyle(MenuPickerStyle())
                            
                        Picker("Ano", selection: $anoSelecionado) {
                            ForEach(2023...2030, id: \.self) { Text("\($0)") }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    // Salários
                    HStack {
                        HStack {
                            Text("R$").foregroundColor(.gray)
                            TextField("Salário Marido", text: $salarioMarido)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .salarioMarido)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack {
                            Text("R$").foregroundColor(.gray)
                            TextField("Salário Esposa", text: $salarioEsposa)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .salarioEsposa)
                        }
                        .padding()
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Botão Adicionar Gasto
                    Button("➕ Adicionar Gasto") { mostrarAdicionarGasto = true }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Lista de gastos filtrados
                    ForEach(gastosFiltrados) { g in
                        HStack {
                            Text(Categoria(rawValue: g.categoria ?? "")?.emoji ?? "❓")
                            VStack(alignment: .leading) {
                                Text("\(g.categoria ?? "") \(g.subCategoria ?? "")")
                                Text("R$ \(g.valor, specifier: "%.2f") (\(g.formaPagamento ?? ""))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Circle()
                                .fill((g.pessoa == "marido") ? Color.blue : Color.pink)
                                .frame(width: 15, height: 15)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Gráficos
                    GraficoEntradasSaidas(
                        gastos: gastosFiltrados,
                        salarioMarido: Double(salarioMarido) ?? 0,
                        salarioEsposa: Double(salarioEsposa) ?? 0
                    )
                    GraficoGastosPorPessoa(gastos: gastosFiltrados)
                    GraficoPercentualPorCategoria(
                        gastos: gastosFiltrados,
                        salarioMarido: Double(salarioMarido) ?? 0,
                        salarioEsposa: Double(salarioEsposa) ?? 0
                    )
                    GraficoPizzaPorCategoria(gastos: gastosFiltrados)
                    
                    // Exportação CSV/PDF
                    HStack {
                        Button("📄 CSV") {
                            let csv = CSVExportManager.gerarCSV(gastos: gastosFiltrados)
                            if let url = CSVExportManager.salvarCSV(
                                nomeArquivo: "Gastos_\(mesSelecionado)_\(anoSelecionado)",
                                csvString: csv
                            ) {
                                print("CSV salvo em: \(url)")
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        
                        Button("📄 PDF") {
                            let pdfView = ScrollView {
                                VStack {
                                    GraficoEntradasSaidas(
                                        gastos: gastosFiltrados,
                                        salarioMarido: Double(salarioMarido) ?? 0,
                                        salarioEsposa: Double(salarioEsposa) ?? 0
                                    )
                                    GraficoGastosPorPessoa(gastos: gastosFiltrados)
                                    GraficoPercentualPorCategoria(
                                        gastos: gastosFiltrados,
                                        salarioMarido: Double(salarioMarido) ?? 0,
                                        salarioEsposa: Double(salarioEsposa) ?? 0
                                    )
                                    GraficoPizzaPorCategoria(gastos: gastosFiltrados)
                                }
                            }
                            
                            PDFExportManager.gerarPDF(
                                from: pdfView,
                                nomeArquivo: "Gastos_\(mesSelecionado)_\(anoSelecionado)",
                                onCompletion: { url in
                                    if let url = url {
                                        print("PDF salvo em: \(url)")
                                    } else {
                                        print("Erro ao gerar PDF.")
                                    }
                                }
                            )
                        }
                        .padding()
                        .background(Color.purple.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }
                // Tornar áreas vazias “tocáveis” + fechar teclado ao tocar fora
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }
            }
            // Botão "Concluído" na barra do teclado (vale para qualquer TextField focado)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Concluído") { focusedField = nil }
                }
            }
            .navigationTitle("Gerenciador de Gastos")
            .sheet(isPresented: $mostrarAdicionarGasto) {
                AdicionarGastoView(controller: controller)
            }
        }
    }
}
