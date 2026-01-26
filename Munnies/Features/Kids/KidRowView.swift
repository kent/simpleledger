import SwiftUI

struct KidRowView: View {
    @ObservedObject var kid: Kid
    @StateObject private var currencyManager = CurrencyManager.shared
    var shareStatus: PersistenceController.KidShareStatus?

    var body: some View {
        HStack(spacing: 16) {
            // Avatar - larger with shadow
            ZStack {
                Circle()
                    .fill(Color(hex: kid.displayColor).opacity(0.2))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hex: kid.displayColor).opacity(0.3), radius: 4, x: 0, y: 2)

                Text(kid.avatarEmoji ?? "\u{1F464}")
                    .font(.system(size: 28))
            }

            // Name and last activity
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(kid.name ?? "Unknown")
                        .font(.headline)

                    // Share indicator badge
                    if let status = shareStatus, status.isShared {
                        Image(systemName: status.isOwner ? "person.2.fill" : "person.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }

                if let lastTransaction = kid.sortedTransactions.first {
                    Text(lastTransaction.createdAt ?? Date(), style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No transactions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Balance - improved typography
            Text(kid.balance, format: .currency(code: currencyManager.currencyCode))
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(kid.balance >= 0 ? .primary : .red)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 127, 255) // Default blue
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    List {
        KidRowView(kid: {
            let context = PersistenceController.preview.container.viewContext
            let kid = Kid(context: context)
            kid.id = UUID()
            kid.name = "Emma"
            kid.avatarEmoji = "👧"
            kid.colorHex = "FF6B6B"

            let t = Transaction(context: context)
            t.id = UUID()
            t.amount = NSDecimalNumber(value: 25.0)
            t.createdAt = Date()
            t.kid = kid

            return kid
        }())
    }
}
