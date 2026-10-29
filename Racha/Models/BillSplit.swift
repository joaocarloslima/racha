import Foundation

/// Splits the party bill evenly among everyone.
/// All money values are in cents.
struct BillSplit: Equatable, Sendable {
    var purchases: [Purchase]
    var participants: [Participant]

    init(purchases: [Purchase], participants: [String]) {
        self.purchases = purchases
        self.participants = participants.map { Participant(name: $0) }
    }

    /// Shortcut for quick scenarios: a single purchase of `total`
    /// split among `people` generic participants.
    init(total: Int, people: Int) {
        let names = people > 0 ? (1...people).map { "Person \($0)" } : []
        self.init(
            purchases: [Purchase(buyer: "Person 1", amount: total)],
            participants: names
        )
    }

    var total: Int {
        purchases.reduce(0) { $0 + $1.amount }
    }

    /// How much each participant owes, in the same order as `participants`.
    /// The cents left over from the division go to the first participants,
    /// one cent each, so the shares always add up to the total.
    /// Returns an empty array when there is nobody to split with.
    func shares() -> [Int] {
        let count = participants.count
        guard count > 0 else { return [] }

        let base = total / count
        let remainder = total % count
        return (0..<count).map { index in
            index < remainder ? base + 1 : base
        }
    }

    func amountPaid(by name: String) -> Int {
        purchases
            .filter { $0.buyer == name }
            .reduce(0) { $0 + $1.amount }
    }

    /// Positive: the person gets money back. Negative: the person still has to pay.
    /// Returns nil when the name is not part of the split.
    func balance(of name: String) -> Int? {
        guard let index = participants.firstIndex(where: { $0.name == name }) else {
            return nil
        }
        return amountPaid(by: name) - shares()[index]
    }
}

extension BillSplit {
    /// A small Integration Day used in examples and tests.
    static let integrationDaySample = BillSplit(
        purchases: [
            Purchase(buyer: "Ana", amount: 12000, item: "Pizza", category: .food),
            Purchase(buyer: "Bia", amount: 4500, item: "Refrigerante", category: .drinks),
            Purchase(buyer: "Caio", amount: 3500, item: "Salgadinhos", category: .snacks)
        ],
        participants: ["Ana", "Bia", "Caio", "Duda", "Edu"]
    )
}
