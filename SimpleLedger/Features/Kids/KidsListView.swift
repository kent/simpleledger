import SwiftUI
import CoreData

struct KidsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var cloudKitManager = CloudKitManager.shared

    @State private var privateKids: [Kid] = []
    @State private var sharedKids: [Kid] = []
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
            .navigationTitle("SimpleLedger")
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
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Kids Yet", systemImage: "person.3")
        } description: {
            Text("Add your first child to start tracking their money.")
        } actions: {
            Button("Add Child") {
                showingAddKid = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var kidsList: some View {
        List {
            Section {
                NavigationLink {
                    JointLedgerView()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Balance")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(totalBalance, format: .currency(code: CurrencyManager.shared.currencyCode))
                                .font(.title.bold())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Joint Ledger")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // My Ledgers section (private kids)
            if !privateKids.isEmpty {
                Section("My Ledgers") {
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
                }
            }

            // Shared with Me section
            if !sharedKids.isEmpty {
                Section("Shared with Me") {
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
                }
            }
        }
        .navigationDestination(for: Kid.self) { kid in
            KidDetailView(kid: kid)
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

// MARK: - Notification Name Extension

extension Notification.Name {
    static let didAcceptCloudKitShare = Notification.Name("didAcceptCloudKitShare")
}

#Preview {
    KidsListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PersistenceController.preview)
}
