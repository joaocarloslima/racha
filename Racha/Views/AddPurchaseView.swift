import SwiftUI

/// Sheet to register a new purchase.
struct AddPurchaseView: View {
    let participants: [String]
    let onSave: (Purchase) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var buyer = ""
    @State private var item = ""
    @State private var amountText = ""
    @State private var category: PurchaseCategory = .food

    private var amount: Int? {
        guard let cents = Money.cents(from: amountText), cents > 0 else { return nil }
        return cents
    }

    private var canSave: Bool {
        !buyer.isEmpty && amount != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quem pagou") {
                    Picker("Pessoa", selection: $buyer) {
                        Text("Escolha").tag("")
                        ForEach(participants, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                }

                Section("O que foi comprado") {
                    categoryGrid
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    TextField("Descrição (ex.: 3 pizzas)", text: $item)
                }

                Section {
                    HStack {
                        Text("R$")
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2.weight(.semibold))
                            .monospacedDigit()
                    }
                } header: {
                    Text("Valor")
                } footer: {
                    if !amountText.isEmpty && amount == nil {
                        Text("Digite um valor maior que zero, tipo 45,90.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Nova compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
            ForEach(PurchaseCategory.allCases) { option in
                Button {
                    category = option
                } label: {
                    VStack(spacing: 6) {
                        CategoryIcon(category: option)
                        Text(option.title)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        option == category ? option.color.opacity(0.18) : Color.clear,
                        in: .rect(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(option == category ? option.color : .clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.title)
                .accessibilityAddTraits(option == category ? .isSelected : [])
            }
        }
    }

    private func save() {
        guard let amount else { return }
        onSave(Purchase(buyer: buyer, amount: amount, item: item, category: category))
        dismiss()
    }
}

#Preview {
    AddPurchaseView(participants: ["Ana", "Bia", "Caio"]) { _ in }
}
