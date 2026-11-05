import SwiftUI

/// Read-only screen: the bill summary and who pays whom.
struct BalanceView: View {
    let viewModel: BillSplitViewModel
    @State private var isShowingSettlement = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    summary
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                participantsSection
            }
            .navigationTitle("Racha")
            .safeAreaInset(edge: .bottom) { closeBillButton }
            .sheet(isPresented: $isShowingSettlement) {
                SettlementView(bill: viewModel.bill)
            }
        }
    }

    // MARK: - Summary

    private var summary: some View {
        VStack(spacing: 12) {
            totalCard
            HStack(spacing: 12) {
                StatCard(
                    title: "Pessoas",
                    value: "\(peopleCount)",
                    systemImage: "person.2.fill",
                    color: .blue
                )
                StatCard(
                    title: "Cada um",
                    value: Money.format(cents: sharePerPerson),
                    systemImage: "divide",
                    color: .purple
                )
                StatCard(
                    title: "Compras",
                    value: "\(viewModel.purchases.count)",
                    systemImage: "cart.fill",
                    color: .orange
                )
            }
        }
    }

    private var totalCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Total da festa", systemImage: "party.popper.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
            Text(Money.format(cents: viewModel.total))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.accentColor.gradient, in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Participants

    @ViewBuilder
    private var participantsSection: some View {
        switch viewModel.state {
        case .loading:
            Section {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Chamando a turma…")
                        .foregroundStyle(.secondary)
                }
            }
        case .failed:
            Section {
                ContentUnavailableView {
                    Label("Não deu pra carregar a turma", systemImage: "wifi.exclamationmark")
                } actions: {
                    Button("Tentar de novo") {
                        Task { await viewModel.loadParticipants() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        case .empty:
            Section {
                ContentUnavailableView(
                    "Ninguém na turma ainda",
                    systemImage: "person.3",
                    description: Text("Quando a lista chegar, o acerto aparece aqui.")
                )
            }
        case .loaded:
            Section("Quem paga pra quem") {
                if viewModel.purchases.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma compra ainda",
                        systemImage: "cart.badge.plus",
                        description: Text("Cadastre o que foi comprado na aba Compras.")
                    )
                } else {
                    let bill = viewModel.bill
                    let transfers = bill.settlements()
                    ForEach(viewModel.participants, id: \.self) { name in
                        if let balance = bill.balance(of: name) {
                            BalanceRow(name: name, balance: balance, transfers: transfers)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Close bill

    private var closeBillButton: some View {
        Button {
            isShowingSettlement = true
        } label: {
            Label("Fechar conta", systemImage: "checkmark.seal.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
        .background(.bar)
        .disabled(!viewModel.canCloseBill)
        .accessibilityIdentifier("closeBillButton")
    }

    // MARK: - Helpers

    private var peopleCount: Int {
        viewModel.participants.count
    }

    private var sharePerPerson: Int {
        viewModel.bill.shares().first ?? 0
    }
}

#Preview {
    BalanceView(viewModel: BillSplitViewModel())
}
