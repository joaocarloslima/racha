import Foundation

/// What kind of thing was bought. Used only to make the list easier to read.
enum PurchaseCategory: String, CaseIterable, Identifiable, Sendable {
    case food
    case drinks
    case snacks
    case sweets
    case decoration
    case other

    var id: String { rawValue }

    /// Label shown on screen.
    var title: String {
        switch self {
        case .food: "Comida"
        case .drinks: "Bebida"
        case .snacks: "Salgadinho"
        case .sweets: "Doce"
        case .decoration: "Decoração"
        case .other: "Outro"
        }
    }
}
