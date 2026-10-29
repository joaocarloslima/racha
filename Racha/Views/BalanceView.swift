import SwiftUI

/// Read-only screen: the bill summary and who owes what.
struct BalanceView: View {
    let viewModel: BillSplitViewModel
    @State private var isShowingSummary = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    summaryCard
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                participantsSection
            }
            .navigationTitle("Racha")
            .safeAreaInset(edge: .bottom) { closeBillButton }
            .alert("Conta fechada", isPresented: $isShowingSummary) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(summaryText)
            }
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total da festa")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Text(Money.format(cents: viewModel.total))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            HStack(spacing: 24) {
                summaryItem(
                    title: "Pessoas",
                    value: "\(viewModel.participants.count)",
                    systemImage: "person.2.fill"
                )
                summaryItem(
                    title: "Por pessoa",
                    value: Money.format(cents: sharePerPerson),
                    systemImage: "divide.circle.fill"
                )
                summaryItem(
                    title: "Compras",
                    value: "\(viewModel.purchases.count)",
                    systemImage: "cart.fill"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.accentColor.gradient, in: .rect(cornerRadius: 20))
    }

    private func summaryItem(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            Text(value)
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.white)
        }
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
            Section("Quem deve pra quem") {
                if viewModel.purchases.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma compra ainda",
                        systemImage: "cart.badge.plus",
                        description: Text("Cadastre o que foi comprado na aba Compras.")
                    )
                } else {
                    ForEach(viewModel.participants, id: \.self) { name in
                        if let balance = viewModel.bill.balance(of: name) {
                            balanceRow(name: name, balance: balance)
                        }
                    }
                }
            }
        }
    }

    private func balanceRow(name: String, balance: Int) -> some View {
        let style = BalanceStyle(balance: balance)
        return HStack(spacing: 12) {
            ParticipantAvatar(name: name)
            Text(name)
            Spacer()
            Label(style.text, systemImage: style.systemImage)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(style.color)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Close bill

    private var closeBillButton: some View {
        Button {
            isShowingSummary = true
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

    private var sharePerPerson: Int {
        viewModel.bill.shares().first ?? 0
    }

    private var summaryText: String {
        "Total de \(Money.format(cents: viewModel.total)) para \(viewModel.participants.count) pessoas."
    }
}

#Preview {
    BalanceView(viewModel: BillSplitViewModel())
}
