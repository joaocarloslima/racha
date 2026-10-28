import SwiftUI

struct BillSplitView: View {
    @State private var viewModel = BillSplitViewModel()
    @State private var buyer = ""
    @State private var item = ""
    @State private var amountText = ""
    @State private var isShowingSummary = false

    var body: some View {
        NavigationStack {
            List {
                participantsSection
                purchasesSection
                if viewModel.canCloseBill {
                    balancesSection
                }
            }
            .navigationTitle("Racha")
            .safeAreaInset(edge: .bottom) { closeBillButton }
            .task { await viewModel.loadParticipants() }
            .alert("Conta fechada", isPresented: $isShowingSummary) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(summaryText)
            }
        }
    }

    // MARK: - Sections

    private var participantsSection: some View {
        Section("Turma") {
            switch viewModel.state {
            case .loading:
                ProgressView("Chamando a turma…")
            case .failed:
                VStack(alignment: .leading, spacing: 8) {
                    Label("Não deu pra carregar a turma.", systemImage: "wifi.exclamationmark")
                    Button("Tentar de novo") {
                        Task { await viewModel.loadParticipants() }
                    }
                }
            case .empty:
                Text("Ninguém na turma ainda.")
            case .loaded:
                Text("\(viewModel.participants.count) pessoas na festa")
            }
        }
    }

    private var purchasesSection: some View {
        Section("Compras") {
            ForEach(viewModel.purchases) { purchase in
                HStack {
                    VStack(alignment: .leading) {
                        Text(purchase.item.isEmpty ? "Compra" : purchase.item)
                        Text(purchase.buyer)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(Money.format(cents: purchase.amount))
                        .monospacedDigit()
                }
            }
            .onDelete { viewModel.removePurchases(at: $0) }

            Picker("Quem pagou", selection: $buyer) {
                Text("Escolha").tag("")
                ForEach(viewModel.participants, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            TextField("O que comprou", text: $item)
            TextField("Valor (ex.: 45,90)", text: $amountText)
                .keyboardType(.decimalPad)
            Button("Adicionar compra", action: addPurchase)
                .disabled(buyer.isEmpty || Money.cents(from: amountText) == nil)

            HStack {
                Text("Total")
                Spacer()
                Text(Money.format(cents: viewModel.total))
                    .bold()
                    .monospacedDigit()
            }
        }
    }

    private var balancesSection: some View {
        Section("Acerto") {
            ForEach(viewModel.participants, id: \.self) { name in
                if let balance = viewModel.bill.balance(of: name) {
                    HStack {
                        Text(name)
                        Spacer()
                        Text(balanceText(balance))
                            .foregroundStyle(balance > 0 ? Color.green : Color.primary)
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private var closeBillButton: some View {
        Button {
            isShowingSummary = true
        } label: {
            Text("Fechar conta")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
        .disabled(!viewModel.canCloseBill)
        .accessibilityIdentifier("closeBillButton")
    }

    // MARK: - Helpers

    private var summaryText: String {
        "Total de \(Money.format(cents: viewModel.total)) para \(viewModel.participants.count) pessoas."
    }

    private func balanceText(_ balance: Int) -> String {
        if balance > 0 { return "recebe \(Money.format(cents: balance))" }
        if balance < 0 { return "paga \(Money.format(cents: -balance))" }
        return "tá quite"
    }

    private func addPurchase() {
        guard let cents = Money.cents(from: amountText) else { return }
        viewModel.add(Purchase(buyer: buyer, amount: cents, item: item))
        item = ""
        amountText = ""
    }
}

#Preview {
    BillSplitView()
}
