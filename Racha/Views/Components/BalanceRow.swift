import SwiftUI

/// One person in the balance list: what they receive, or whom they pay.
struct BalanceRow: View {
    let name: String
    let balance: Int
    let transfers: [Transfer]

    private var paying: [Transfer] { transfers.filter { $0.from == name } }
    private var receiving: [Transfer] { transfers.filter { $0.to == name } }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ParticipantAvatar(name: name)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.body.weight(.semibold))
                details
                    .font(.subheadline)
                    .monospacedDigit()
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var details: some View {
        if balance > 0 {
            Label("recebe \(Money.format(cents: balance))", systemImage: "arrow.down.left.circle.fill")
                .foregroundStyle(.green)
            Text(receiving.count == 1 ? "de 1 pessoa" : "de \(receiving.count) pessoas")
                .foregroundStyle(.secondary)
        } else if balance < 0 {
            if paying.isEmpty {
                Label("paga \(Money.format(cents: -balance))", systemImage: "arrow.up.right.circle.fill")
                    .foregroundStyle(.red)
            } else {
                ForEach(paying) { transfer in
                    Label(
                        "paga \(Money.format(cents: transfer.amount)) pra \(transfer.to)",
                        systemImage: "arrow.up.right.circle.fill"
                    )
                    .foregroundStyle(.red)
                }
            }
        } else {
            Label("tá quite", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let bill = BillSplit.integrationDaySample
    let transfers = bill.settlements()
    List(bill.participants) { participant in
        BalanceRow(
            name: participant.name,
            balance: bill.balance(of: participant.name) ?? 0,
            transfers: transfers
        )
    }
}
