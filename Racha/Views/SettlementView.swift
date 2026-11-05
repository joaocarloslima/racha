import SwiftUI

/// Final settlement: the transfers grouped by who receives,
/// with a message ready to send to the class group chat.
struct SettlementView: View {
    let bill: BillSplit
    @Environment(\.dismiss) private var dismiss

    private var transfers: [Transfer] { bill.settlements() }

    /// People who receive money, in the order they first appear in the transfers.
    private var receivers: [String] {
        var names: [String] = []
        for transfer in transfers where !names.contains(transfer.to) {
            names.append(transfer.to)
        }
        return names
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label(pixCountText, systemImage: "arrow.left.arrow.right")
                        Spacer()
                        Text(Money.format(cents: bill.total))
                            .monospacedDigit()
                            .bold()
                    }
                } footer: {
                    Text("Cada pessoa faz um Pix só, pra quem está indicado.")
                }

                ForEach(receivers, id: \.self) { receiver in
                    Section {
                        ForEach(transfers.filter { $0.to == receiver }) { transfer in
                            HStack(spacing: 12) {
                                ParticipantAvatar(name: transfer.from, size: 30)
                                Text(transfer.from)
                                Spacer()
                                Text(Money.format(cents: transfer.amount))
                                    .monospacedDigit()
                            }
                            .accessibilityElement(children: .combine)
                        }
                    } header: {
                        HStack(spacing: 8) {
                            ParticipantAvatar(name: receiver, size: 22)
                            Text("Pix pra \(receiver)")
                            Spacer()
                            Text(Money.format(cents: totalReceived(by: receiver)))
                                .monospacedDigit()
                        }
                    }
                }
            }
            .overlay {
                if transfers.isEmpty {
                    ContentUnavailableView(
                        "Ninguém deve nada",
                        systemImage: "checkmark.seal",
                        description: Text("Todo mundo já pagou a sua parte.")
                    )
                }
            }
            .navigationTitle("Acerto final")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ShareLink(item: message, preview: SharePreview("Acerto do racha")) {
                    Label("Mandar no grupo da turma", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(.bar)
                .disabled(transfers.isEmpty)
            }
        }
    }

    private var pixCountText: String {
        transfers.count == 1 ? "1 Pix pra fazer" : "\(transfers.count) Pix pra fazer"
    }

    private func totalReceived(by name: String) -> Int {
        transfers
            .filter { $0.to == name }
            .reduce(0) { $0 + $1.amount }
    }

    /// Plain text for the group chat.
    private var message: String {
        var lines = [
            "Racha do Integration Day",
            "Total: \(Money.format(cents: bill.total))",
            ""
        ]
        for receiver in receivers {
            lines.append("Pix pra \(receiver):")
            for transfer in transfers where transfer.to == receiver {
                lines.append("• \(transfer.from): \(Money.format(cents: transfer.amount))")
            }
            lines.append("")
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    SettlementView(bill: .integrationDaySample)
}
