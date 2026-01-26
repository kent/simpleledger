import SwiftUI
import CoreData

struct KidsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var cloudKitManager = CloudKitManager.shared

    @State private var privateKids: [Kid] = []
    @State private var sharedKids: [Kid] = []
    @State private var allTransactions: [Transaction] = []
    @State private var showingAddKid = false
    @State private var showingSettings = false
    @State private var kidToShare: Kid?
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

    private var totalBalance: Decimal {
        (privateKids + sharedKids).reduce(Decimal.zero) { $0 + $1.balance }
    }

    private var allKids: [Kid] {
        privateKids + sharedKids
    }

    var body: some View {
        NavigationStack {
            Group {
                if allKids.isEmpty {
                    emptyState
                } else {
                    kidsList
                }
            }
            .navigationTitle("Munnies")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddKid = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddKid) {
                AddKidSheet()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let kid = kidToShare {
                    KidCloudSharingView(
                        kid: kid,
                        persistenceController: persistenceController,
                        isPresented: $showShareSheet
                    )
                }
            }
            .onAppear {
                refreshKids()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                refreshKids()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
                refreshKids()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didAcceptCloudKitShare)) { _ in
                refreshKids()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveRemoteChanges)) { _ in
                refreshKids()
            }
            .onReceive(NotificationCenter.default.publisher(for: .shareAcceptanceFailed)) { notification in
                if let error = notification.userInfo?["error"] as? String {
                    errorMessage = error
                    showingErrorAlert = true
                }
            }
            .alert("Sharing Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }

    private func refreshKids() {
        let result = persistenceController.fetchAllKids()
        withAnimation {
            privateKids = result.privateKids
            sharedKids = result.sharedKids
        }
        refreshTransactions()
    }

    private func refreshTransactions() {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.createdAt, ascending: false)]
        request.fetchLimit = 20 // Show most recent 20 transactions

        do {
            allTransactions = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch transactions: \(error)")
            allTransactions = []
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            // Piggy bank illustration
            HStack(spacing: -8) {
                Text("\u{1F437}")
                    .font(.system(size: 60))
                Text("\u{1F4B0}")
                    .font(.system(size: 50))
            }

            VStack(spacing: 8) {
                Text("Start Tracking")
                    .font(.title2.bold())

                Text("Add your first child to keep track of their savings, gifts, and spending.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showingAddKid = true
            } label: {
                Label("Add Child", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())

            Spacer()
        }
    }

    private var kidsList: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total Balance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(totalBalance, format: .currency(code: CurrencyManager.shared.currencyCode))
                            .font(.system(size: 36, weight: .bold, design: .rounded))

                        HStack(spacing: 12) {
                            Label("\(allKids.count) ledger\(allKids.count == 1 ? "" : "s")", systemImage: "book.closed.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !sharedKids.isEmpty {
                                Label("\(sharedKids.count) shared", systemImage: "person.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // My Ledgers section (private kids)
            if !privateKids.isEmpty {
                Section {
                    ForEach(privateKids) { kid in
                        NavigationLink(value: kid) {
                            KidRowView(kid: kid, shareStatus: persistenceController.shareStatus(for: kid))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                deleteKid(kid)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)

                            if cloudKitManager.isSignedIntoiCloud {
                                Button {
                                    kidToShare = kid
                                    showShareSheet = true
                                } label: {
                                    Label("Share", systemImage: "person.badge.plus")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                } header: {
                    Label("My Ledgers", systemImage: "book.closed.fill")
                        .textCase(nil)
                }
            }

            // Shared with Me section
            if !sharedKids.isEmpty {
                Section {
                    ForEach(sharedKids) { kid in
                        NavigationLink(value: kid) {
                            KidRowView(kid: kid, shareStatus: persistenceController.shareStatus(for: kid))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                leaveShare(kid)
                            } label: {
                                Label("Stop Viewing", systemImage: "eye.slash")
                            }
                            .tint(.orange)
                        }
                    }
                } header: {
                    Label("Shared with Me", systemImage: "person.2.fill")
                        .textCase(nil)
                }
            }

            // Recent Activity section
            Section {
                if allTransactions.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No transactions yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                } else {
                    ForEach(allTransactions, id: \.id) { transaction in
                        TransactionRowWithKid(transaction: transaction)
                    }
                }
            } header: {
                Label("Recent Activity", systemImage: "clock.fill")
                    .textCase(nil)
            }
        }
        .navigationDestination(for: Kid.self) { kid in
            KidDetailView(kid: kid)
        }
    }

    // MARK: - Transaction Row with Kid Info

    private struct TransactionRowWithKid: View {
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

        private var creatorName: String? {
            // Only show creator name if it exists and is different from current user
            guard let name = transaction.createdByName, !name.isEmpty else { return nil }
            let currentUser = CloudKitManager.shared.currentUserName
            if let currentUser = currentUser, name == currentUser {
                return nil // Don't show if it's the current user
            }
            return name
        }

        var body: some View {
            HStack(spacing: 12) {
                // Kid Avatar
                ZStack {
                    Circle()
                        .fill(kidColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Text(kidEmoji)
                        .font(.subheadline)
                }

                // Details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(kidName)
                            .font(.subheadline.weight(.medium))

                        if let note = transaction.note, !note.isEmpty {
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    HStack(spacing: 4) {
                        if let creator = creatorName {
                            Text(creator)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("·")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(relativeTimeString(from: transaction.createdAt ?? Date()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Amount
                Text(amount, format: .currency(code: currencyManager.currencyCode))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isDeposit ? .green : .red)
            }
            .padding(.vertical, 2)
        }
    }

    private func deleteKid(_ kid: Kid) {
        withAnimation {
            viewContext.delete(kid)
            persistenceController.save()
            refreshKids()
        }
    }

    private func leaveShare(_ kid: Kid) {
        Task {
            do {
                try await persistenceController.leaveShare(for: kid)
                await MainActor.run {
                    refreshKids()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to stop viewing: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Relative Time Helper

private func relativeTimeString(from date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}

// MARK: - Notification Name Extension

extension Notification.Name {
    static let didAcceptCloudKitShare = Notification.Name("didAcceptCloudKitShare")
}

#Preview {
    KidsListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PersistenceController.preview)
}
