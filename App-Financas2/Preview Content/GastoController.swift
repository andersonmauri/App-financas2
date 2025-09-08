// GastoController.swift
import Foundation
import CoreData
import Combine

class GastoController: ObservableObject {

    @Published var gastos: [GastoEntity] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        carregarGastos()
    }

    // MARK: - Carregar gastos (mais recentes primeiro)
    func carregarGastos() {
        let request: NSFetchRequest<GastoEntity> = GastoEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \GastoEntity.data, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            self.gastos = try context.fetch(request)
        } catch {
            print("Erro ao carregar gastos: \(error.localizedDescription)")
        }
    }

    // MARK: - Filtrar por mês e ano
    func filtrarPorMesAno(gastos: [GastoEntity], mes: Int, ano: Int) -> [GastoEntity] {
        let calendar = Calendar.current
        return gastos.filter { gasto in
            guard let data = gasto.data else { return false }
            let components = calendar.dateComponents([.month, .year], from: data)
            return components.month == mes && components.year == ano
        }
    }

    // MARK: - Adicionar gasto simples
    func adicionarGasto(categoria: String,
                        subCategoria: String?,
                        valor: Double,
                        pessoa: String,
                        formaPagamento: String,
                        mes: Int? = nil,
                        ano: Int? = nil) {

        let novoGasto = GastoEntity(context: context)
        novoGasto.categoria = categoria
        novoGasto.subCategoria = subCategoria
        novoGasto.valor = valor
        novoGasto.pessoa = pessoa
        novoGasto.formaPagamento = formaPagamento

        let now = Date()
        if let mes = mes, let ano = ano {
            let current = Calendar.current.dateComponents([.month, .year], from: now)
            if current.month == mes && current.year == ano {
                // Sempre usar data atual para o mês selecionado
                novoGasto.data = now
            } else {
                var dc = DateComponents()
                dc.year = ano
                dc.month = mes
                dc.day = 1
                novoGasto.data = Calendar.current.date(from: dc)
            }
        } else {
            novoGasto.data = now
        }

        salvarContexto()
    }

    // MARK: - Adicionar gasto parcelado
    func adicionarGastoParcelado(categoria: String,
                                 subCategoria: String?,
                                 valorTotal: Double,
                                 pessoa: String,
                                 formaPagamento: String,
                                 numeroParcelas: Int,
                                 mesInicial: Int,
                                 anoInicial: Int) {

        guard numeroParcelas > 0 else { return }
        let valorParcela = valorTotal / Double(numeroParcelas)

        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.day, from: now)
        var mesAjustado = mesInicial
        var anoAjustado = anoInicial

        if formaPagamento == "Crédito" && currentDay > 30 {
            mesAjustado += 1
        }

        func normalize(mes: Int, ano: Int) -> (mes: Int, ano: Int) {
            var m = mes
            var a = ano
            while m > 12 { m -= 12; a += 1 }
            while m <= 0 { m += 12; a -= 1 }
            return (m, a)
        }

        for i in 0..<numeroParcelas {
            let candidateMes = mesAjustado + i
            let normalized = normalize(mes: candidateMes, ano: anoAjustado)
            let mesParcela = normalized.mes
            let anoParcela = normalized.ano

            let novoGasto = GastoEntity(context: context)
            novoGasto.categoria = categoria

            if let sub = subCategoria, !sub.trimmingCharacters(in: .whitespaces).isEmpty {
                novoGasto.subCategoria = "\(sub) - Parcela \(i + 1)/\(numeroParcelas)"
            } else {
                novoGasto.subCategoria = "Parcela \(i + 1)/\(numeroParcelas)"
            }

            novoGasto.valor = valorParcela
            novoGasto.pessoa = pessoa
            novoGasto.formaPagamento = formaPagamento

            if i == 0 {
                let current = Calendar.current.dateComponents([.month, .year], from: now)
                if current.month == mesParcela && current.year == anoParcela {
                    novoGasto.data = now
                } else {
                    var dc = DateComponents()
                    dc.year = anoParcela
                    dc.month = mesParcela
                    dc.day = 1
                    novoGasto.data = calendar.date(from: dc)
                }
            } else {
                var dc = DateComponents()
                dc.year = anoParcela
                dc.month = mesParcela
                dc.day = 1
                novoGasto.data = calendar.date(from: dc)
            }
        }

        salvarContexto()
    }

    // MARK: - Excluir gasto
    func excluirGasto(gasto: GastoEntity) {
        context.delete(gasto)
        salvarContexto()
    }

    // MARK: - Salvar contexto
    private func salvarContexto() {
        do {
            try context.save()
            carregarGastos()
        } catch {
            print("Erro ao salvar contexto: \(error)")
        }
    }
}
