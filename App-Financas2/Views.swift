import SwiftUI
import Charts

// MARK: - Adicionar Gasto View
struct AdicionarGastoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var controller: GastoController
    
    @State private var pessoa: Pessoa = .marido
    @State private var categoria: Categoria = .Agua
    @State private var subCategoria: SubCategoria? = nil
    @State private var  casaSubCategoria: CasaSubCategoria? = nil
    @State private var  refeicao: Refeicao? = nil
    @State private var  igreja: Igreja? = nil
    @State private var  filhos: Filhos? = nil
    @State private var  vestuario: Vestuário? = nil
    @State private var valor: String = ""
    @State private var formaPagamento: FormaPagamento = .dinheiro
    @State private var data: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Pessoa", selection: $pessoa) {
                    ForEach(Pessoa.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                
                Picker("Categoria", selection: $categoria) {
                    ForEach(Categoria.allCases, id: \.self) {
                        Text("\($0.emoji) \($0.rawValue.capitalized)")
                    }
                }
                .onChange(of: categoria) { _ in
                    subCategoria = categoria == .Carro ? .prestacao : nil
                    casaSubCategoria = categoria == .Casa ? .Manutenção : nil
                    refeicao = categoria == .Refeicao ? .Café : nil
                    igreja = categoria == .Igreja ? .Cantina : nil
                    vestuario = categoria == .Vestuário ? .Calçado : nil
                    filhos = categoria == .Filhos ? .Escola : nil

                }
                
                if categoria == .Carro {
                    Picker("Qual foi o seu gasto?", selection: $subCategoria) {
                        ForEach(SubCategoria.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                if categoria == .Casa {
                    Picker("Qual foi o seu  Gasto?", selection: $casaSubCategoria) {
                        ForEach(CasaSubCategoria.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                if categoria == .Refeicao {
                    Picker("Qual foi a sua Refeição?", selection: $refeicao) {
                        ForEach(Refeicao.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                if categoria == .Igreja {
                    Picker("Qual foi o seu  Gasto?", selection: $igreja) {
                        ForEach(Igreja.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                if categoria == .Vestuário {
                    Picker("Qual foi o seu  Gasto?", selection: $vestuario) {
                        ForEach(Vestuário.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                if categoria == .Filhos {
                    Picker("Qual foi o seu  Gasto?", selection: $filhos) {
                        ForEach(Filhos.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    
                }
                
                HStack {
                    Text("R$").foregroundColor(.gray)
                    TextField("Valor", text: $valor)
                        .keyboardType(.decimalPad)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Picker("Forma de Pagamento", selection: $formaPagamento) {
                    ForEach(FormaPagamento.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                }
                
                DatePicker("Data", selection: $data, displayedComponents: .date)
            }
            .navigationTitle("Adicionar Gasto")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if let v = Double(valor.replacingOccurrences(of: ",", with: ".")) {
                            controller.adicionarGasto(
                                categoria: categoria.rawValue,
                                subCategoria: subCategoria?.rawValue,
                                valor: v,
                                pessoa: pessoa.rawValue,
                                formaPagamento: formaPagamento.rawValue
                            )
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
            }
        }
    }
}


// MARK: - Gráficos

struct GraficoEntradasSaidas: View {
    let gastos: [GastoEntity]; let salarioMarido: Double; let salarioEsposa: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("💰 Entradas vs Saídas").font(.headline)
            Chart {
                BarMark(x: .value("Tipo", "Salário Marido"), y: .value("Valor", salarioMarido)).foregroundStyle(.blue)
                BarMark(x: .value("Tipo", "Salário Esposa"), y: .value("Valor", salarioEsposa)).foregroundStyle(.pink)
                BarMark(x: .value("Tipo", "Gastos Marido"),
                        y: .value("Valor", gastos.filter{ $0.pessoa == "marido" }.reduce(0){$0+$1.valor}))
                .foregroundStyle(.blue.opacity(0.6))
                BarMark(x: .value("Tipo", "Gastos Esposa"),
                        y: .value("Valor", gastos.filter{ $0.pessoa == "esposa" }.reduce(0){$0+$1.valor}))
                .foregroundStyle(.pink.opacity(0.6))
            }.frame(height: 200)
        }.padding()
    }
}

struct GraficoGastosPorPessoa: View {
    let gastos: [GastoEntity]
    var body: some View {
        VStack(alignment: .leading) {
            Text("📊 Gastos por Pessoa").font(.headline)
            Chart {
                BarMark(x: .value("Pessoa", "Marido"),
                        y: .value("Valor", gastos.filter{ $0.pessoa == "marido" }.reduce(0){$0+$1.valor}))
                .foregroundStyle(.blue)
                BarMark(x: .value("Pessoa", "Esposa"),
                        y: .value("Valor", gastos.filter{ $0.pessoa == "esposa" }.reduce(0){$0+$1.valor}))
                .foregroundStyle(.pink)
            }.frame(height: 200)
        }.padding()
    }
}

struct GraficoPercentualPorCategoria: View {
    let gastos: [GastoEntity]; let salarioMarido: Double; let salarioEsposa: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📈 Percentual por Categoria").font(.headline)
            
            ForEach(Categoria.allCases, id: \.self) { c in
                let gm = gastos.filter { $0.pessoa == "marido" && $0.categoria == c.rawValue }.reduce(0) { $0 + $1.valor }
                let ge = gastos.filter { $0.pessoa == "esposa" && $0.categoria == c.rawValue }.reduce(0) { $0 + $1.valor }
                
                HStack {
                    Text("\(c.emoji) \(c.rawValue.capitalized)")
                    Spacer()
                    Text("👨 \(salarioMarido > 0 ? String(format: "%.1f%%", gm / salarioMarido * 100) : "0%")").foregroundColor(.blue)
                    Text("👩 \(salarioEsposa > 0 ? String(format: "%.1f%%", ge / salarioEsposa * 100) : "0%")").foregroundColor(.pink)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
    }
}

struct GraficoPizzaPorCategoria: View {
    let gastos: [GastoEntity]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("🥧 Distribuição por Categoria").font(.headline)
            
            Chart {
                ForEach(Categoria.allCases, id: \.self) { c in
                    let total = gastos.filter { $0.categoria == c.rawValue }.reduce(0) { $0 + $1.valor }
                    if total > 0 {
                        SectorMark(angle: .value("Valor", total), innerRadius: .ratio(0.5))
                            .foregroundStyle(by: .value("Categoria", c.rawValue))
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .center)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 250)
        }
        .padding()
    }
}
