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

    static let classList = [
        "Ana", "Bia", "Caio", "Duda", "Edu", "Fê", "Gabi", "Hugo",
        "Iris", "João", "Kaique", "Lara", "Malu", "Nina", "Otto", "Paula",
        "Rafa", "Sofia", "Téo", "Vini", "Wesley", "Yara", "Zeca"
    ]
}
