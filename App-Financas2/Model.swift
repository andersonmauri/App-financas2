import Foundation
import CoreData

// MARK: - Enums auxiliares
enum Pessoa: String, CaseIterable {
    case marido, esposa
}

enum Categoria: String, CaseIterable {
    case agua, luz, internet, ifood, feira, cafeLanche, comprasMes, cartaoCredito, farmacia, filhos, roupas, calcados, carro
    
    var emoji: String {
        switch self {
        case .agua: return "💧"
        case .luz: return "⚡"
        case .internet: return "🌐"
        case .ifood: return "🍔"
        case .feira: return "🥬"
        case .cafeLanche: return "☕"
        case .comprasMes: return "🛒"
        case .cartaoCredito: return "💳"
        case .farmacia: return "💊"
        case .filhos: return "👶"
        case .roupas: return "👕"
        case .calcados: return "👟"
        case .carro: return "🚗"
        }
    }
}

enum SubCategoria: String, CaseIterable {
    case prestacao, gasolina, manutencao
}

enum FormaPagamento: String, CaseIterable {
    case dinheiro, pix, cartaoCredito, outros
}
