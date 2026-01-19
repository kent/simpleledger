import SwiftUI
import CoreData

struct TransactionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    @ObservedObject var kid: Kid

    var body: some View {
        List {
            ForEach(kid.sortedTransactions, id: \.id) { transaction in
                TransactionRowView(transaction: transaction)
            }
            .onDelete(perform: deleteTransactions)
        }
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            let transactions = kid.sortedTransactions
            offsets.map { transactions[$0] }.forEach(viewContext.delete)
            persistenceController.save()
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView(kid: {
            let context = PersistenceController.preview.container.viewContext
            let kid = Kid(context: context)
            kid.id = UUID()
            kid.name = "Emma"

            for i in 0..<20 {
                let t = Transaction(context: context)
                t.id = UUID()
                t.amount = NSDecimalNumber(value: Double.random(in: -50...100))
                t.note = i % 3 == 0 ? "Transaction \(i)" : nil
                t.createdAt = Date().addingTimeInterval(-Double(i) * 86400)
                t.kid = kid
            }

            return kid
        }())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(PersistenceController.preview)
}
