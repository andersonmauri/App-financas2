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
    
    func filtrarPorMesAno(gastos: [GastoEntity], mes: Int, ano: Int) -> [GastoEntity] {
        let calendar = Calendar.current
        return gastos.filter { gasto in
            let components = calendar.dateComponents([.month, .year], from: gasto.data ?? Date())
            return components.month == mes && components.year == ano
        }
    }
    
    func adicionarGasto(categoria: String, subCategoria: String?, valor: Double, pessoa: String, formaPagamento: String) {
        let novoGasto = GastoEntity(context: context)
        novoGasto.categoria = categoria
        novoGasto.subCategoria = subCategoria
        novoGasto.valor = valor
        novoGasto.pessoa = pessoa
        novoGasto.formaPagamento = formaPagamento
        novoGasto.data = Date()
        
        do {
            try context.save()
            carregarGastos()
        } catch {
            print("Erro ao salvar o gasto: \(error.localizedDescription)")
        }
    }
}
