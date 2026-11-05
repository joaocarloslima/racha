import Foundation

/// Anything that can provide the list of people in the class.
protocol ParticipantsService: Sendable {
    func fetch() async throws -> [String]
}

/// Stands in for the class API. There is no real server:
/// it waits a moment, like a slow network call, and returns the class list.
struct APIParticipantsService: ParticipantsService {
    var delay: Duration = .seconds(1)

    func fetch() async throws -> [String] {
        try await Task.sleep(for: delay)
        return Self.classList
    }

    /// The 30 people in the class. Surnames only where first names repeat.
    static let classList = [
        "Agatha", "Ana", "André", "Elisa", "Emily", "Felipe",
        "Gabriel", "Guilherme Sales", "Guilherme Souza", "Igor", "Isabella", "João Souza",
        "João Wandermuren", "Joice", "Juan", "Julio", "Leonardo", "Lucas",
        "Maria", "Mariana", "Mirella", "Paulo", "Pedro Canute", "Pedro Silveira",
        "Pedro Teruel", "Rebeca", "Sarah", "Tais", "Vinicius", "Vitor"
    ]
}
