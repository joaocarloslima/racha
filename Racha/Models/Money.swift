import Foundation

/// Converts between cents and the text people read and type.
enum Money {
    /// 4590 becomes "R$ 45,90". 123456 becomes "R$ 1.234,56".
    static func format(cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        let value = abs(cents)
        let reais = groupThousands(value / 100)
        let centavos = String(format: "%02ld", value % 100)
        return "\(sign)R$ \(reais),\(centavos)"
    }

    /// Reads what the user typed: "45,90", "45.90", "45" or "1.234,56".
    /// Returns nil when the text is not a valid amount.
    static func cents(from text: String) -> Int? {
        var cleaned = text
            .replacingOccurrences(of: "R$", with: "")
            .trimmingCharacters(in: .whitespaces)

        if cleaned.contains(",") {
            cleaned = cleaned
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")
        }

        let parts = cleaned.split(separator: ".", omittingEmptySubsequences: false)
        guard !cleaned.isEmpty, parts.count <= 2 else { return nil }

        let wholePart = String(parts[0])
        guard wholePart.allSatisfy(\.isNumber) else { return nil }
        let reais = wholePart.isEmpty ? 0 : (Int(wholePart) ?? 0)

        var fraction = 0
        if parts.count == 2 {
            let fractionPart = String(parts[1])
            guard fractionPart.count <= 2, fractionPart.allSatisfy(\.isNumber) else { return nil }
            fraction = Int(fractionPart.padding(toLength: 2, withPad: "0", startingAt: 0)) ?? 0
        }

        return reais * 100 + fraction
    }

    private static func groupThousands(_ number: Int) -> String {
        let digits = String(number)
        var result = ""
        for (offset, digit) in digits.enumerated() {
            if offset > 0 && (digits.count - offset) % 3 == 0 {
                result.append(".")
            }
            result.append(digit)
        }
        return result
    }
}
