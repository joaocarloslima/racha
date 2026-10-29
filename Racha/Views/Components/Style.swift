import SwiftUI

extension PurchaseCategory {
    var systemImage: String {
        switch self {
        case .food: "fork.knife"
        case .drinks: "cup.and.saucer.fill"
        case .snacks: "takeoutbag.and.cup.and.straw.fill"
        case .sweets: "birthday.cake.fill"
        case .decoration: "balloon.2.fill"
        case .other: "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: .orange
        case .drinks: .blue
        case .snacks: .yellow
        case .sweets: .pink
        case .decoration: .purple
        case .other: .gray
        }
    }
}

/// Rounded square with the category symbol, like the icons in Settings.
struct CategoryIcon: View {
    let category: PurchaseCategory

    var body: some View {
        Image(systemName: category.systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(category.color.gradient, in: .rect(cornerRadius: 9))
            .accessibilityHidden(true)
    }
}

/// Circle with the person's initial. The color is always the same for the same name.
struct ParticipantAvatar: View {
    let name: String
    var size: CGFloat = 36

    private static let palette: [Color] = [.orange, .blue, .green, .pink, .purple, .teal, .indigo, .mint, .red, .cyan]

    private var color: Color {
        let seed = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palette[seed % Self.palette.count]
    }

    var body: some View {
        Text(name.prefix(1).uppercased())
            .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: .circle)
            .accessibilityHidden(true)
    }
}

/// How a balance is shown: who receives, who pays, who is even.
struct BalanceStyle {
    let text: String
    let systemImage: String
    let color: Color

    init(balance: Int) {
        if balance > 0 {
            text = "recebe \(Money.format(cents: balance))"
            systemImage = "arrow.down.circle.fill"
            color = .green
        } else if balance < 0 {
            text = "paga \(Money.format(cents: -balance))"
            systemImage = "arrow.up.circle.fill"
            color = .red
        } else {
            text = "tá quite"
            systemImage = "checkmark.circle.fill"
            color = .secondary
        }
    }
}
