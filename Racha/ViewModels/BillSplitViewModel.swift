import Foundation
import Observation

@MainActor
@Observable
final class BillSplitViewModel {
    enum LoadState: Equatable, Sendable {
        case loading
        case empty
        case failed
        case loaded
    }

    private(set) var purchases: [Purchase] = []
    private(set) var participants: [String] = []
    private(set) var state: LoadState = .loading

    @ObservationIgnored
    private let service: any ParticipantsService

    init(service: any ParticipantsService = APIParticipantsService()) {
        self.service = service
    }

    var total: Int {
        purchases.reduce(0) { $0 + $1.amount }
    }

    var canCloseBill: Bool {
        !purchases.isEmpty && !participants.isEmpty
    }

    var bill: BillSplit {
        BillSplit(purchases: purchases, participants: participants)
    }

    /// Ignores purchases without a buyer or without a positive amount.
    func add(_ purchase: Purchase) {
        guard purchase.amount > 0, !purchase.buyer.isEmpty else { return }
        purchases.append(purchase)
    }

    func removePurchases(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            purchases.remove(at: index)
        }
    }

    func loadParticipants() async {
        state = .loading
        do {
            let names = try await service.fetch()
            participants = names
            state = names.isEmpty ? .empty : .loaded
        } catch {
            participants = []
            state = .failed
        }
    }
}
