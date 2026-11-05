import Foundation

/// Splits the party bill evenly among everyone.
/// All money values are in cents.
struct BillSplit: Equatable, Sendable {
    var purchases: [Purchase]
    var participants: [Participant]

    init(purchases: [Purchase], participants: [String], absentees: Set<String> = []) {
        self.purchases = purchases
        self.participants = participants.map {
            Participant(name: $0, attended: !absentees.contains($0))
        }
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

    /// How much each attendee owes. People who did not attend pay nothing.
    /// Returns an empty array when nobody attended.
    func shares() -> [Int] {
        let attendees = participants.filter { $0.attended }
        guard !attendees.isEmpty else { return [] }
        let share = total / attendees.count
        return Array(repeating: share, count: attendees.count)
    }

    func amountPaid(by name: String) -> Int {
        purchases
            .filter { $0.buyer == name }
            .reduce(0) { $0 + $1.amount }
    }

    /// Positive: the person gets money back. Negative: the person still has to pay.
    /// Returns nil when the name is not part of the split.
    func balance(of name: String) -> Int? {
        guard let person = participants.first(where: { $0.name == name }) else {
            return nil
        }
        guard person.attended else { return amountPaid(by: name) }

        let attendees = participants.filter { $0.attended }
        guard let index = attendees.firstIndex(where: { $0.name == name }) else {
            return nil
        }
        return amountPaid(by: name) - shares()[index]
    }

    /// Who pays whom so everyone ends up even.
    /// The people who owe the most pay the people who are owed the most first,
    /// which keeps the number of transfers small.
    func settlements() -> [Transfer] {
        var creditors: [(name: String, amount: Int)] = []
        var debtors: [(name: String, amount: Int)] = []

        for participant in participants {
            guard let balance = balance(of: participant.name) else { continue }
            if balance > 0 {
                creditors.append((participant.name, balance))
            } else if balance < 0 {
                debtors.append((participant.name, -balance))
            }
        }

        let largestFirst: ((name: String, amount: Int), (name: String, amount: Int)) -> Bool = {
            $0.amount != $1.amount ? $0.amount > $1.amount : $0.name < $1.name
        }
        creditors.sort(by: largestFirst)
        debtors.sort(by: largestFirst)

        var transfers: [Transfer] = []
        var debtorIndex = 0
        var creditorIndex = 0

        while debtorIndex < debtors.count && creditorIndex < creditors.count {
            let value = min(debtors[debtorIndex].amount, creditors[creditorIndex].amount)
            transfers.append(Transfer(
                from: debtors[debtorIndex].name,
                to: creditors[creditorIndex].name,
                amount: value
            ))
            debtors[debtorIndex].amount -= value
            creditors[creditorIndex].amount -= value

            if debtors[debtorIndex].amount == 0 { debtorIndex += 1 }
            if creditors[creditorIndex].amount == 0 { creditorIndex += 1 }
        }

        return transfers
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
