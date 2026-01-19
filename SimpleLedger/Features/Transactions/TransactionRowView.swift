import SwiftUI
import CoreData

struct TransactionRowView: View {
    @ObservedObject var transaction: Transaction
    @StateObject private var currencyManager = CurrencyManager.shared

    private var isDeposit: Bool {
        (transaction.amount as Decimal? ?? 0) >= 0
    }

    private var amount: Decimal {
        transaction.amount as Decimal? ?? 0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(isDeposit ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: isDeposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isDeposit ? .green : .red)
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .lineLimit(1)
                } else {
                    Text(isDeposit ? "Deposit" : "Withdrawal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(transaction.createdAt ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(amount, format: .currency(code: currencyManager.currencyCode))
                .font(.headline)
                .foregroundStyle(isDeposit ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        TransactionRowView(transaction: {
            let context = PersistenceController.preview.container.viewContext
            let t = Transaction(context: context)
            t.id = UUID()
            t.amount = NSDecimalNumber(value: 25.0)
            t.note = "Birthday money from Grandma"
            t.createdAt = Date()
            return t
        }())

        TransactionRowView(transaction: {
            let context = PersistenceController.preview.container.viewContext
            let t = Transaction(context: context)
            t.id = UUID()
            t.amount = NSDecimalNumber(value: -5.0)
            t.note = "Ice cream"
            t.createdAt = Date().addingTimeInterval(-86400)
            return t
        }())

        TransactionRowView(transaction: {
            let context = PersistenceController.preview.container.viewContext
            let t = Transaction(context: context)
            t.id = UUID()
            t.amount = NSDecimalNumber(value: 100.0)
            t.createdAt = Date().addingTimeInterval(-86400 * 7)
            return t
        }())
    }
}
