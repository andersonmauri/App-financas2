import Foundation
import CoreData

// MARK: - Enums auxiliares
enum Pessoa: String, CaseIterable {
    case marido, esposa
}

enum Categoria: String, CaseIterable {
    case Agua, Luz, Internet, Ifood, Feira, Refeicao, Mercado, Credito, Farmacia, Filhos, Vestuário, Carro, Igreja, Casa
    
    var emoji: String {
        switch self {
        case .Agua: return "💧"
        case .Luz: return "⚡"
        case .Internet: return "🌐"
        case .Ifood: return "🍔"
        case .Feira: return "🥬"
        case .Refeicao: return "🍽️"
        case .Mercado: return "🛒"
        case .Credito: return "💳"
        case .Farmacia: return "💊"
        case .Filhos: return "👶"
        case .Vestuário: return "👕"
        case .Carro: return "🚗"
        case .Igreja: return "⛪️"
        case .Casa: return "🏠"
        }
    }
}

enum SubCategoria: String, CaseIterable {
    case prestacao, gasolina, manutencao
}

enum Refeicao: String, CaseIterable {
    case Café, Almoço, Lanche, Janta
}

enum CasaSubCategoria: String, CaseIterable {
    case Manutenção, Reforma, Móveis, Eletrodomesticos
}

enum Igreja: String, CaseIterable {
    case Cantina, Dizimo, Doação
}

enum FormaPagamento: String, CaseIterable {
    case dinheiro, pix, Crédito, outros
}

enum Filhos: String, CaseIterable {
    case Roupa, Calçado, Escola, Diversos
}

enum Vestuário: String, CaseIterable {
    case Roupa, Calçado, Diversos
}
