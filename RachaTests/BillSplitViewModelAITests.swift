import Testing
@testable import Racha

// Written by an AI assistant. All 8 tests pass.
// Your job: find out which ones actually protect something.

private struct AIGeneratedFakeService: ParticipantsService {
    var names: [String] = ["Ana", "Bia", "Caio"]

    func fetch() async throws -> [String] {
        names
    }
}

@MainActor
@Suite(.serialized)
struct BillSplitViewModelAITests {

    static let sharedViewModel = BillSplitViewModel(service: AIGeneratedFakeService())

    @Test func newPurchaseUpdatesTotal() {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())

        viewModel.add(Purchase(buyer: "Ana", amount: 8000))
        viewModel.add(Purchase(buyer: "Bia", amount: 4500))

        #expect(viewModel.total == 12500)
    }

    @Test func ignoresPurchasesWithoutAmount() {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())

        viewModel.add(Purchase(buyer: "Ana", amount: 0))
        viewModel.add(Purchase(buyer: "Bia", amount: -500))

        #expect(viewModel.purchases.isEmpty)
        #expect(viewModel.total == 0)
    }

    @Test func cannotCloseBillBeforeParticipantsArrive() {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())

        viewModel.add(Purchase(buyer: "Ana", amount: 3000))

        #expect(viewModel.canCloseBill == false)
    }

    @Test func addingPurchaseWorks() {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())

        viewModel.add(Purchase(buyer: "Ana", amount: 3000))

        #expect(viewModel.total >= 0)
    }

    @Test func extraCentGoesToFirstPerson() async {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())
        await viewModel.loadParticipants()

        viewModel.add(Purchase(buyer: "Ana", amount: 10000))

        #expect(viewModel.bill.shares() == [3334, 3333, 3333])
    }

    @Test func fullBillFlow() async {
        let viewModel = BillSplitViewModel(service: AIGeneratedFakeService())
        #expect(viewModel.state == .loading)

        await viewModel.loadParticipants()
        viewModel.add(Purchase(buyer: "Ana", amount: 6000))
        viewModel.add(Purchase(buyer: "Bia", amount: 3000))

        #expect(
            viewModel.state == .loaded
            && viewModel.participants.count == 3
            && viewModel.total == 9000
            && viewModel.canCloseBill
            && viewModel.bill.balance(of: "Ana") == 3000
            && viewModel.bill.balance(of: "Caio") == -3000
        )
    }

    @Test func test1() {
        Self.sharedViewModel.add(Purchase(buyer: "Ana", amount: 5000))

        #expect(Self.sharedViewModel.purchases.count == 1)
    }

    @Test func totalKeepsEarlierPurchases() {
        Self.sharedViewModel.add(Purchase(buyer: "Bia", amount: 2000))

        #expect(Self.sharedViewModel.total == 7000)
    }
}
