import Foundation

/// Something a person bought for the party and paid for in advance.
/// `amount` is always in cents: R$ 45,90 is 4590.
struct Purchase: Identifiable, Equatable, Sendable {
    let id = UUID()
    let buyer: String
    let amount: Int
    var item: String = ""
}
