import Foundation

/// A person taking part in the bill split.
struct Participant: Identifiable, Equatable, Sendable {
    let name: String
    var attended: Bool = true

    var id: String { name }
}
