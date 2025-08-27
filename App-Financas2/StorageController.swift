import Foundation
import CoreData
import SwiftUI

// StorageController.swift
import CoreData
import Foundation
import Combine

class StorageController: ObservableObject {
    private var viewContext: NSManagedObjectContext
    
    // Inicializador que recebe o viewContext
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // ... (o restante dos seus métodos)
    
    func salvar() {
        do {
            try viewContext.save()
        } catch {
            print("Erro ao salvar gasto: \(error)")
        }
    }
    
    func filtrarPorMesAno(gastos: [GastoEntity], mes: Int, ano: Int) -> [GastoEntity] {
        gastos.filter {
            guard let data = $0.data else { return false }
            let comp = Calendar.current.dateComponents([.year, .month], from: data)
            return comp.month == mes && comp.year == ano
        }
    }
    
    func totalPorPessoa(gastos: [GastoEntity], pessoa: Pessoa) -> Double {
        gastos.filter { $0.pessoa == pessoa.rawValue }.reduce(0) { $0 + $1.valor }
    }
    
    func totalPorCategoria(gastos: [GastoEntity], pessoa: Pessoa, categoria: Categoria) -> Double {
        gastos.filter { $0.pessoa == pessoa.rawValue && $0.categoria == categoria.rawValue }
            .reduce(0) { $0 + $1.valor }
    }
}

