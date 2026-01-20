import SwiftUI
import CoreData

struct JointLedgerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var currencyManager = CurrencyManager.shared

    @State private var allTransactions: [Transaction] = []
    @State private var selectedFilter: TransactionFilter = .all

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case deposits = "Deposits"
        case withdrawals = "Spending"
    }

    private var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all:
            return allTransactions
        case .deposits:
            return allTransactions.filter { ($0.amount as Decimal? ?? 0) >= 0 }
        case .withdrawals:
            return allTransactions.filter { ($0.amount as Decimal? ?? 0) < 0 }
        }
    }

    private var totalDeposits: Decimal {
        allTransactions
            .map { $0.amount as Decimal? ?? 0 }
            .filter { $0 > 0 }
            .reduce(0, +)
    }

    private var totalWithdrawals: Decimal {
        allTransactions
            .map { $0.amount as Decimal? ?? 0 }
            .filter { $0 < 0 }
            .reduce(0, +)
    }

    private var netTotal: Decimal {
        totalDeposits + totalWithdrawals
    }

    var body: some View {
        List {
            // Summary Section
            Section {
                VStack(spacing: 16) {
                    // Net total
                    VStack(spacing: 4) {
                        Text("Net Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(netTotal, format: .currency(code: currencyManager.currencyCode))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(netTotal >= 0 ? .primary : .red)
                    }

                    // Deposits and Withdrawals
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundStyle(.green)
                                Text("In")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)

                            Text(totalDeposits, format: .currency(code: currencyManager.currencyCode))
                                .font(.headline)
                                .foregroundStyle(.green)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundStyle(.red)
                                Text("Out")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)

                            Text(abs(totalWithdrawals), format: .currency(code: currencyManager.currencyCode))
                                .font(.headline)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            // Filter Picker
            Section {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            // Transactions List
            Section {
                if filteredTransactions.isEmpty {
                    ContentUnavailableView {
                        Label("No Transactions", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text("Transactions from all kids will appear here.")
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredTransactions, id: \.id) { transaction in
                        JointTransactionRowView(transaction: transaction)
                    }
                }
            } header: {
                if !filteredTransactions.isEmpty {
                    Text("\(filteredTransactions.count) transactions")
                }
            }
        }
        .navigationTitle("Joint Ledger")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAllTransactions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            loadAllTransactions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveRemoteChanges)) { _ in
            loadAllTransactions()
        }
    }

    private func loadAllTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.createdAt, ascending: false)]

        do {
            allTransactions = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch transactions: \(error)")
            allTransactions = []
        }
    }
}

// MARK: - Joint Transaction Row (shows kid info)

struct JointTransactionRowView: View {
    @ObservedObject var transaction: Transaction
    @StateObject private var currencyManager = CurrencyManager.shared

    private var isDeposit: Bool {
        (transaction.amount as Decimal? ?? 0) >= 0
    }

    private var amount: Decimal {
        transaction.amount as Decimal? ?? 0
    }

    private var kidName: String {
        transaction.kid?.name ?? "Unknown"
    }

    private var kidEmoji: String {
        transaction.kid?.avatarEmoji ?? "👤"
    }

    private var kidColor: Color {
        Color(hex: transaction.kid?.colorHex ?? "007AFF")
    }

    var body: some View {
        HStack(spacing: 12) {
            // Kid Avatar
            ZStack {
                Circle()
                    .fill(kidColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Text(kidEmoji)
                    .font(.title3)
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(kidName)
                        .font(.subheadline.weight(.medium))

                    if let note = transaction.note, !note.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
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
    NavigationStack {
        JointLedgerView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(PersistenceController.preview)
}
