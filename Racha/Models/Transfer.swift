import Foundation

/// One payment needed to settle the bill: `from` pays `amount` (in cents) to `to`.
struct Transfer: Identifiable, Equatable, Sendable {
    let from: String
    let to: String
    let amount: Int

    var id: String { "\(from)->\(to)" }
}
