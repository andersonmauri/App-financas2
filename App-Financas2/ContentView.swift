// ContentView.swift
import SwiftUI
import CoreData
import Charts


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var controller: GastoController

    @State private var salarioMarido: String = ""
    @State private var salarioEsposa: String = ""
    @FocusState private var focusedField: Bool
    @State private var mesSelecionado = Calendar.current.component(.month, from: Date())
    @State private var anoSelecionado = Calendar.current.component(.year, from: Date())
    @State private var mostrarAdicionarGasto = false
    @State private var salarioGuardadoMsg: String? = nil

    // Filtra os gastos do mês/ano selecionado
    var gastosFiltrados: [GastoEntity] {
        controller.filtrarPorMesAno(gastos: controller.gastos, mes: mesSelecionado, ano: anoSelecionado)
    }

    // Total de gastos do mês selecionado
    var totalGastos: Double {
        gastosFiltrados.reduce(0) { $0 + $1.valor }
    }

    // Total de salários disponíveis
    var totalSalarios: Double {
        (Double(salarioMarido) ?? 0) + (Double(salarioEsposa) ?? 0)
    }

    // Saldo restante
    var saldoRestante: Double {
        totalSalarios - totalGastos
    }

    private var chaveSalarioMarido: String { "salarioMarido_\(mesSelecionado)_\(anoSelecionado)" }
    private var chaveSalarioEsposa: String { "salarioEsposa_\(mesSelecionado)_\(anoSelecionado)" }

    private func carregarSalarios() {
        salarioMarido = UserDefaults.standard.string(forKey: chaveSalarioMarido) ?? ""
        salarioEsposa = UserDefaults.standard.string(forKey: chaveSalarioEsposa) ?? ""
        salarioGuardadoMsg = (salarioMarido.isEmpty && salarioEsposa.isEmpty) ? nil : "Salários Armazenados"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Filtro Mês/Ano
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
                    .onChange(of: mesSelecionado) { _ in carregarSalarios() }
                    .onChange(of: anoSelecionado) { _ in carregarSalarios() }

                    // Campos de salário
                    HStack {
                        Text("R$").foregroundColor(.gray)
                        TextField("Salário Marido", text: $salarioMarido)
                            .keyboardType(.decimalPad)
                            .focused($focusedField)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }.padding(.horizontal)

                    HStack {
                        Text("R$").foregroundColor(.gray)
                        TextField("Salário Esposa", text: $salarioEsposa)
                            .keyboardType(.decimalPad)
                            .focused($focusedField)
                            .padding()
                            .background(Color.pink.opacity(0.1))
                            .cornerRadius(8)
                    }.padding(.horizontal)

                    // Guardar salários
                    Button("💾 Guardar") {
                        UserDefaults.standard.set(salarioMarido, forKey: chaveSalarioMarido)
                        UserDefaults.standard.set(salarioEsposa, forKey: chaveSalarioEsposa)
                        salarioGuardadoMsg = "Salários Armazenados"
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                    if let msg = salarioGuardadoMsg {
                        VStack(spacing: 6) {
                            Text(msg).foregroundColor(.green).bold()
                            if !salarioMarido.isEmpty { Text("Marido: R$ \(salarioMarido)").foregroundColor(.blue) }
                            if !salarioEsposa.isEmpty { Text("Esposa: R$ \(salarioEsposa)").foregroundColor(.pink) }
                        }.padding(.horizontal)
                    }

                    // Botão Adicionar Gasto
                    Button("➕ Adicionar Gasto") { mostrarAdicionarGasto = true }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    // Ordena por data decrescente (mais recentes primeiro)
                    let gastosOrdenados = gastosFiltrados.sorted { g1, g2 in
                        guard let d1 = g1.data, let d2 = g2.data else { return g1.data != nil }
                        return d1 > d2
                    }

                    // Lista de gastos
                    if !gastosOrdenados.isEmpty {
                        List {
                            ForEach(gastosOrdenados) { g in
                                HStack {
                                    Text(Categoria(rawValue: g.categoria ?? "")?.emoji ?? "❓")

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(g.categoria ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        if let sub = g.subCategoria, !sub.isEmpty {
                                            Text(sub)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }

                                        Text("R$ \(g.valor, specifier: "%.2f") (\(g.formaPagamento ?? ""))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        if let data = g.data {
                                            Text("📅 \(data.formatted(.dateTime.day().month().year()))")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    Spacer()

                                    Circle()
                                        .fill((g.pessoa == "marido") ? Color.blue : Color.pink)
                                        .frame(width: 15, height: 15)
                                }
                            }
                            .onDelete { indices in
                                for index in indices {
                                    let gasto = gastosOrdenados[index]
                                    controller.excluirGasto(gasto: gasto)
                                }
                            }
                        }
                        .frame(height: 300)

                        // Soma dos gastos
                        HStack {
                            Text("💰 Total de Gastos:")
                                .font(.headline)
                            Spacer()
                            Text("R$ \(totalGastos, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)

                        // Saldo restante
                        HStack {
                            Text("💵 Saldo Restante:")
                                .font(.headline)
                            Spacer()
                            Text("R$ \(saldoRestante, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(saldoRestante >= 0 ? .green : .red)
                        }
                        .padding(.horizontal)

                        Spacer().frame(height: 12)
                    }

                    // Gráficos e exportação permanecem iguais
                    GraficoEntradasSaidas(
                        gastos: gastosOrdenados,
                        salarioMarido: Double(salarioMarido) ?? 0,
                        salarioEsposa: Double(salarioEsposa) ?? 0
                    )
                    GraficoGastosPorPessoa(gastos: gastosOrdenados)
                    GraficoPercentualPorCategoria(
                        gastos: gastosOrdenados,
                        salarioMarido: Double(salarioMarido) ?? 0,
                        salarioEsposa: Double(salarioEsposa) ?? 0
                    )
                    GraficoPizzaPorCategoria(gastos: gastosOrdenados)

                    HStack {
                        Button("📄 CSV") {
                            let csv = CSVExportManager.gerarCSV(gastos: gastosOrdenados)
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
                                        gastos: gastosOrdenados,
                                        salarioMarido: Double(salarioMarido) ?? 0,
                                        salarioEsposa: Double(salarioEsposa) ?? 0
                                    )
                                    GraficoGastosPorPessoa(gastos: gastosOrdenados)
                                    GraficoPercentualPorCategoria(
                                        gastos: gastosOrdenados,
                                        salarioMarido: Double(salarioMarido) ?? 0,
                                        salarioEsposa: Double(salarioEsposa) ?? 0
                                    )
                                    GraficoPizzaPorCategoria(gastos: gastosOrdenados)
                                }
                            }
                            PDFExportManager.gerarPDF(
                                from: pdfView,
                                nomeArquivo: "Gastos_\(mesSelecionado)_\(anoSelecionado)"
                            ) { url in
                                if let url = url {
                                    print("PDF salvo em: \(url)")
                                } else {
                                    print("Erro ao gerar PDF.")
                                }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }
                .contentShape(Rectangle())
                .onTapGesture { focusedField = false }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Concluído") { focusedField = false }
                }
            }
            .navigationTitle("Gerenciador de Gastos")
            .sheet(isPresented: $mostrarAdicionarGasto) {
                AdicionarGastoSheet(controller: controller, mesAtual: mesSelecionado, anoAtual: anoSelecionado)
            }
            .onAppear { carregarSalarios() }
        }
    }
}

// MARK: - Sheet de Adicionar Gasto (mantido igual)
struct AdicionarGastoSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var controller: GastoController

    var mesAtual: Int
    var anoAtual: Int

    @State private var categoriaSelecionada: Categoria = .Agua
    @State private var subCategoria: String = ""
    @State private var valor: String = ""
    @State private var pessoa: Pessoa = .marido
    @State private var formaPagamento: String = "Dinheiro"
    @State private var mostrarParcelas: Bool = false
    @State private var numeroParcelas: String = ""

    var body: some View {
        NavigationView {
            Form {
                Picker("Categoria", selection: $categoriaSelecionada) {
                    ForEach(Categoria.allCases, id: \.self) { cat in
                        Text("\(cat.emoji) \(cat.rawValue)").tag(cat)
                    }
                }

                TextField("Subcategoria (opcional)", text: $subCategoria)
                TextField("Valor", text: $valor)
                    .keyboardType(.decimalPad)

                Picker("Pessoa", selection: $pessoa) {
                    Text("Marido").tag(Pessoa.marido)
                    Text("Esposa").tag(Pessoa.esposa)
                }

                Picker("Forma de Pagamento", selection: $formaPagamento) {
                    Text("Dinheiro").tag("Dinheiro")
                    Text("Crédito").tag("Crédito")
                    Text("Pix").tag("Pix")
                }
                .onChange(of: formaPagamento) { newValue in
                    mostrarParcelas = newValue == "Crédito"
                }

                if mostrarParcelas {
                    TextField("Número de parcelas", text: $numeroParcelas)
                        .keyboardType(.numberPad)
                }

                Button("Salvar") {
                    guard let valorDouble = Double(valor) else { return }

                    if mostrarParcelas,
                       let parcelas = Int(numeroParcelas),
                       parcelas > 0,
                       formaPagamento == "Crédito" {

                        controller.adicionarGastoParcelado(
                            categoria: categoriaSelecionada.rawValue,
                            subCategoria: subCategoria,
                            valorTotal: valorDouble,
                            pessoa: pessoa.rawValue,
                            formaPagamento: formaPagamento,
                            numeroParcelas: parcelas,
                            mesInicial: mesAtual,
                            anoInicial: anoAtual
                        )
                    } else {
                        controller.adicionarGasto(
                            categoria: categoriaSelecionada.rawValue,
                            subCategoria: subCategoria,
                            valor: valorDouble,
                            pessoa: pessoa.rawValue,
                            formaPagamento: formaPagamento,
                            mes: mesAtual,
                            ano: anoAtual
                        )
                    }

                    dismiss()
                }
            }
            .navigationTitle("Adicionar Gasto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
