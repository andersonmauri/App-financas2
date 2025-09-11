import Foundation
import CoreData

// MARK: - Enums auxiliares

enum CasaSubCategoria: String, CaseIterable {
    case Eletrodomesticos, Manutenção, Móveis, Reforma
}

enum Categoria: String, CaseIterable {
    case Agua, Carro, Casa, Credito, Estudos, Feira, Filhos, Farmacia, Ifood, Igreja, Internet, Luz, Mercado, Refeicao, Vestuário, Viagem, Outros
    
    var emoji: String {
        switch self {
        case .Agua: return "💧"
        case .Carro: return "🚗"
        case .Casa: return "🏠"
        case .Credito: return "💳"
        case .Estudos: return "📕"
        case .Feira: return "🥬"
        case .Filhos: return "👶"
        case .Farmacia: return "💊"
        case .Ifood: return "🍔"
        case .Igreja: return "⛪️"
        case .Internet: return "🌐"
        case .Luz: return "⚡"
        case .Mercado: return "🛒"
        case .Refeicao: return "🍽️"
        case .Vestuário: return "👕"
        case .Viagem: return "✈️"
        case .Outros: return "🤔"
        }
    }
}

enum Filhos: String, CaseIterable {
    case Calçado, Diversos, Escola, Roupa
}

enum FormaPagamento: String, CaseIterable {
    case Crédito, dinheiro, outros, pix
}

enum Igreja: String, CaseIterable {
    case Cantina, Dizimo, Doação
}

enum Pessoa: String, CaseIterable {
    case esposa, marido
}

enum Refeicao: String, CaseIterable {
    case Almoço, Café, Janta, Lanche
}

enum SubCategoria: String, CaseIterable {
    case gasolina, manutencao, prestacao
}

enum Vestuário: String, CaseIterable {
    case Calçado, Diversos, Roupa
}
