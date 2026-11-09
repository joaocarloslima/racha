import SwiftUI

/// List of purchases and the entry point to add a new one.
struct PurchasesView: View {
    let viewModel: BillSplitViewModel
    @State private var isAddingPurchase = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.purchases.isEmpty {
                    ContentUnavailableView {
                        Label("Nenhuma compra ainda", systemImage: "cart")
                    } description: {
                        Text("Quem comprou alguma coisa pra festa cadastra aqui.")
                    } actions: {
                        Button("Adicionar compra") { isAddingPurchase = true }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.participants.isEmpty)
                    }
                } else {
                    purchaseList
                }
            }
            .navigationTitle("Compras")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Adicionar compra", systemImage: "plus.circle.fill") {
                        isAddingPurchase = true
                    }
                    .disabled(viewModel.participants.isEmpty)
                    .accessibilityIdentifier("addPurchaseButton")
                }
            }
            .sheet(isPresented: $isAddingPurchase) {
                AddPurchaseView(participants: viewModel.participants) { purchase in
                    viewModel.add(purchase)
                }
            }
        }
    }

    private var purchaseList: some View {
        List {
            Section {
                ForEach(viewModel.purchases) { purchase in
                    purchaseRow(purchase)
                }
                .onDelete { viewModel.removePurchases(at: $0) }
            } footer: {
                Text("Deslize pra esquerda pra apagar uma compra.")
            }

            Section {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(Money.format(cents: viewModel.total))
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private func purchaseRow(_ purchase: Purchase) -> some View {
        HStack(spacing: 12) {
            CategoryIcon(category: purchase.category)
            VStack(alignment: .leading, spacing: 2) {
                Text(purchase.item.isEmpty ? purchase.category.title : purchase.item)
                Label(purchase.buyer, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Money.format(cents: purchase.amount))
                .font(.body.weight(.semibold))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PurchasesView(viewModel: BillSplitViewModel())
}
