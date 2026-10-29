import SwiftUI

struct RootView: View {
    @State private var viewModel = BillSplitViewModel()

    var body: some View {
        TabView {
            Tab("Acerto", systemImage: "person.3.fill") {
                BalanceView(viewModel: viewModel)
            }
            Tab("Compras", systemImage: "cart.fill") {
                PurchasesView(viewModel: viewModel)
            }
            .badge(viewModel.purchases.count)
        }
        .task { await viewModel.loadParticipants() }
    }
}

#Preview {
    RootView()
}
