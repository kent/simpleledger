import CoreData
import CloudKit

@MainActor
final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    /// Published flag indicating when persistent stores are fully loaded and ready
    @Published private(set) var storesLoaded = false

    /// Error that occurred during store loading, if any
    @Published private(set) var storeLoadError: Error?

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.seedSampleData(forceReset: true)
        return controller
    }()

    let container: NSPersistentCloudKitContainer

    /// The shared store URL for CloudKit shared data
    private var sharedStoreURL: URL {
        let storeURL = container.persistentStoreDescriptions.first!.url!
        return storeURL.deletingLastPathComponent().appendingPathComponent("shared.sqlite")
    }

    /// The private store description
    var privateStoreDescription: NSPersistentStoreDescription? {
        container.persistentStoreDescriptions.first { description in
            guard let url = description.url else { return false }
            return !url.lastPathComponent.contains("shared")
        }
    }

    /// The shared store description
    var sharedStoreDescription: NSPersistentStoreDescription? {
        container.persistentStoreDescriptions.first { description in
            guard let url = description.url else { return false }
            return url.lastPathComponent.contains("shared")
        }
    }

    /// The actual shared persistent store (after loading)
    var sharedPersistentStore: NSPersistentStore? {
        container.persistentStoreCoordinator.persistentStores.first { store in
            store.url?.lastPathComponent.contains("shared") ?? false
        }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Munnies")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure for CloudKit sync with dual stores
            configureCloudKitStores()
        }

        // Track how many stores we expect to load
        let expectedStoreCount = container.persistentStoreDescriptions.count
        var loadedStoreCount = 0

        container.loadPersistentStores { [weak self] storeDescription, error in
            let storeName = storeDescription.url?.lastPathComponent ?? "unknown"

            Task { @MainActor [weak self] in
                if let error {
                    self?.storeLoadError = error
                    print("Persistent store loading failed for \(storeName): \(error)")
                    return
                }

                loadedStoreCount += 1
                print("Loaded store: \(storeName)")

                // Keep the readiness flag in sync once both private and shared stores are available.
                if loadedStoreCount == expectedStoreCount {
                    self?.storesLoaded = true
                    print("All persistent stores loaded successfully")
                }
            }
        }

        // Enable automatic merging of changes from CloudKit
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Set query generation for consistent reads
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print("Failed to set query generation: \(error)")
        }

        // Listen for remote change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    private func configureCloudKitStores() {
        guard let privateDescription = container.persistentStoreDescriptions.first else {
            fatalError("No store descriptions found")
        }

        // Configure private store (user's own data)
        privateDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.ewakened.munnies"
        )
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Configure shared store (data shared via CKShare)
        let sharedDescription = NSPersistentStoreDescription(url: sharedStoreURL)
        sharedDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        sharedDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let sharedOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.ewakened.munnies"
        )
        sharedOptions.databaseScope = .shared
        sharedDescription.cloudKitContainerOptions = sharedOptions

        container.persistentStoreDescriptions.append(sharedDescription)
    }

    @objc nonisolated private func storeRemoteChange(_ notification: Notification) {
        guard let storeUUID = notification.userInfo?[NSStoreUUIDKey] as? String else { return }

        // Process remote changes on a background context
        let context = container.newBackgroundContext()
        context.perform {
            // Fetch the history since last processed
            let historyRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastHistoryToken)

            if let historyResult = try? context.execute(historyRequest) as? NSPersistentHistoryResult,
               let transactions = historyResult.result as? [NSPersistentHistoryTransaction],
               !transactions.isEmpty {

                // Update the token for next time
                self.lastHistoryToken = transactions.last?.token

                // Check if any Kid or Transaction objects changed
                var kidsChanged = false
                var transactionsChanged = false

                for transaction in transactions {
                    if let changes = transaction.changes {
                        for change in changes {
                            if change.changedObjectID.entity.name == "Kid" {
                                kidsChanged = true
                            } else if change.changedObjectID.entity.name == "Transaction" {
                                transactionsChanged = true
                            }
                        }
                    }
                }

                // Post notification on main thread if relevant changes detected
                if kidsChanged || transactionsChanged {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: .didReceiveRemoteChanges,
                            object: nil,
                            userInfo: [
                                "kidsChanged": kidsChanged,
                                "transactionsChanged": transactionsChanged,
                                "storeUUID": storeUUID
                            ]
                        )
                    }
                }
            }
        }
    }

    /// Token for tracking persistent history processing
    nonisolated private var lastHistoryToken: NSPersistentHistoryToken? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "lastHistoryToken") else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
        }
        set {
            if let token = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "lastHistoryToken")
            }
        }
    }

    // MARK: - Store Readiness

    /// Waits for persistent stores to be loaded, with a timeout
    func waitForStoresLoaded(timeout: TimeInterval = 10.0) async -> Bool {
        if storesLoaded { return true }

        let deadline = Date().addingTimeInterval(timeout)

        while !storesLoaded && storeLoadError == nil && Date() < deadline {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        return storesLoaded
    }

    func initializeCloudKitSchema() throws {
        try container.initializeCloudKitSchema(options: [])
    }

    // MARK: - Convenience Methods

    func seedSampleDataIfNeeded() {
        seedSampleData(forceReset: false)
    }

    func resetAndSeedSampleData() {
        seedSampleData(forceReset: true)
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    private func seedSampleData(forceReset: Bool) {
        let context = container.viewContext

        if forceReset {
            clearKidsAndTransactions(in: context)
        } else {
            let existingKids = fetchAllKids()
            guard existingKids.privateKids.isEmpty && existingKids.sharedKids.isEmpty else { return }
        }

        let now = Date()

        let emma = createKid(
            name: "Emma",
            emoji: "👧",
            colorHex: "FF6B6B",
            createdAt: now.addingTimeInterval(-86400 * 28),
            in: context
        )
        addTransaction(
            amount: 80,
            note: "Birthday card from Nana",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 21),
            to: emma,
            in: context
        )
        addTransaction(
            amount: 25,
            note: "Tooth fairy",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 10),
            to: emma,
            in: context
        )
        addTransaction(
            amount: -12.5,
            note: "Craft supplies",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 3),
            to: emma,
            in: context
        )
        addTransaction(
            amount: 40,
            note: "Lemonade stand",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-3600 * 18),
            to: emma,
            in: context
        )

        let jack = createKid(
            name: "Jack",
            emoji: "🧒",
            colorHex: "4ECDC4",
            createdAt: now.addingTimeInterval(-86400 * 22),
            in: context
        )
        addTransaction(
            amount: 60,
            note: "Allowance catch-up",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 14),
            to: jack,
            in: context
        )
        addTransaction(
            amount: -7.75,
            note: "Comic book",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 6),
            to: jack,
            in: context
        )
        addTransaction(
            amount: 35,
            note: "Helped wash the car",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-3600 * 8),
            to: jack,
            in: context
        )

        let sophie = createKid(
            name: "Sophie",
            emoji: "👑",
            colorHex: "F39C12",
            createdAt: now.addingTimeInterval(-86400 * 35),
            in: context
        )
        addTransaction(
            amount: 120,
            note: "Holiday money",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 30),
            to: sophie,
            in: context
        )
        addTransaction(
            amount: 45,
            note: "Babysitting savings",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 12),
            to: sophie,
            in: context
        )
        addTransaction(
            amount: -18,
            note: "Book fair",
            createdByName: "Kent",
            createdAt: now.addingTimeInterval(-86400 * 1),
            to: sophie,
            in: context
        )

        save()
    }

    private func clearKidsAndTransactions(in context: NSManagedObjectContext) {
        let kidRequest = NSFetchRequest<Kid>(entityName: "Kid")

        do {
            let kids = try context.fetch(kidRequest)
            kids.forEach(context.delete)
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to clear sample data: \(error)")
        }
    }

    private func createKid(
        name: String,
        emoji: String,
        colorHex: String,
        createdAt: Date,
        in context: NSManagedObjectContext
    ) -> Kid {
        let kid = Kid(context: context)
        kid.id = UUID()
        kid.name = name
        kid.avatarEmoji = emoji
        kid.colorHex = colorHex
        kid.createdAt = createdAt
        return kid
    }

    private func addTransaction(
        amount: Decimal,
        note: String,
        createdByName: String,
        createdAt: Date,
        to kid: Kid,
        in context: NSManagedObjectContext
    ) {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.note = note
        transaction.createdByName = createdByName
        transaction.createdAt = createdAt
        transaction.kid = kid
    }

    /// Determines which store an object belongs to (private or shared)
    func isShared(object: NSManagedObject) -> Bool {
        guard let persistentStore = object.objectID.persistentStore else {
            return false
        }
        return persistentStore.url?.lastPathComponent.contains("shared") ?? false
    }

    /// Gets all shares for the container
    func fetchShares() throws -> [CKShare] {
        var allShares: [CKShare] = []
        for store in container.persistentStoreCoordinator.persistentStores {
            let shares = try container.fetchShares(in: store)
            allShares.append(contentsOf: shares)
        }
        return allShares
    }

    /// Gets the share for a specific object if it exists
    func fetchShare(for object: NSManagedObject) throws -> CKShare? {
        let objectIDs = [object.objectID]
        let shares = try container.fetchShares(matching: objectIDs)
        return shares[object.objectID]
    }

    // MARK: - Per-Kid Sharing Methods

    /// Fetches all Kids from both private and shared stores
    func fetchAllKids() -> (privateKids: [Kid], sharedKids: [Kid]) {
        let context = container.viewContext
        let request = NSFetchRequest<Kid>(entityName: "Kid")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Kid.name, ascending: true)]

        do {
            let allKids = try context.fetch(request)

            var privateKids: [Kid] = []
            var sharedKids: [Kid] = []

            for kid in allKids {
                if isShared(object: kid) {
                    sharedKids.append(kid)
                } else {
                    privateKids.append(kid)
                }
            }

            return (privateKids, sharedKids)
        } catch {
            print("Failed to fetch kids: \(error)")
            return ([], [])
        }
    }

    /// Sharing status for a Kid
    struct KidShareStatus {
        let isShared: Bool
        let isOwner: Bool
        let participantCount: Int
        let ownerName: String?
        let share: CKShare?
    }

    /// Gets the sharing status for a specific Kid
    func shareStatus(for kid: Kid) -> KidShareStatus {
        do {
            if let share = try fetchShare(for: kid) {
                let currentUserIsOwner = share.currentUserParticipant?.role == .owner
                let ownerName = share.owner.userIdentity.nameComponents?.formatted()
                return KidShareStatus(
                    isShared: true,
                    isOwner: currentUserIsOwner,
                    participantCount: share.participants.count,
                    ownerName: ownerName,
                    share: share
                )
            }

            // Check if kid is in shared store (we're a participant)
            if isShared(object: kid) {
                // We're viewing someone else's shared kid
                // Try to get owner info from the share in the store
                if let store = kid.objectID.persistentStore,
                   let shares = try? container.fetchShares(in: store),
                   let share = shares.first {
                    let ownerName = share.owner.userIdentity.nameComponents?.formatted()
                    return KidShareStatus(
                        isShared: true,
                        isOwner: false,
                        participantCount: share.participants.count,
                        ownerName: ownerName,
                        share: share
                    )
                }
                return KidShareStatus(
                    isShared: true,
                    isOwner: false,
                    participantCount: 0,
                    ownerName: nil,
                    share: nil
                )
            }
        } catch {
            print("Error checking share status: \(error)")
        }

        return KidShareStatus(
            isShared: false,
            isOwner: true,
            participantCount: 0,
            ownerName: nil,
            share: nil
        )
    }

    /// Checks if the current user can edit a Kid (owner or participant with write access)
    func canEdit(kid: Kid) -> Bool {
        do {
            if let share = try fetchShare(for: kid) {
                if let participant = share.currentUserParticipant {
                    return participant.permission == .readWrite || participant.role == .owner
                }
            }
            // If not shared or no participant info, can edit if in private store
            return !isShared(object: kid)
        } catch {
            // Default to editable for private store items
            return !isShared(object: kid)
        }
    }

    /// Creates or retrieves a CKShare for sharing a specific Kid
    func shareKid(_ kid: Kid) async throws -> CKShare {
        // Check for existing share first
        if let existingShare = try fetchShare(for: kid) {
            return existingShare
        }

        // Create new share for this Kid
        let (_, share, _) = try await container.share([kid], to: nil)
        share[CKShare.SystemFieldKey.title] = "\(kid.name ?? "Child")'s Account"

        return share
    }

    /// Stops sharing a Kid (owner only)
    func stopSharing(kid: Kid) async throws {
        guard let share = try fetchShare(for: kid) else { return }

        let cloudContainer = CKContainer(identifier: "iCloud.com.ewakened.munnies")
        try await cloudContainer.privateCloudDatabase.deleteRecord(withID: share.recordID)
    }

    /// Leave a shared Kid (participant only)
    func leaveShare(for kid: Kid) async throws {
        let status = shareStatus(for: kid)
        guard let share = status.share, !status.isOwner else { return }

        let cloudContainer = CKContainer(identifier: "iCloud.com.ewakened.munnies")
        let operation = CKModifyRecordZonesOperation(
            recordZonesToSave: nil,
            recordZoneIDsToDelete: [share.recordID.zoneID]
        )
        operation.qualityOfService = .userInitiated

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.modifyRecordZonesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            cloudContainer.sharedCloudDatabase.add(operation)
        }
    }
}

// MARK: - Kid Helper Extension

extension Kid {
    var balance: Decimal {
        guard let transactions = transactions as? Set<Transaction> else { return 0 }
        return transactions.reduce(Decimal.zero) { sum, transaction in
            sum + (transaction.amount as Decimal? ?? 0)
        }
    }

    var sortedTransactions: [Transaction] {
        guard let transactions = transactions as? Set<Transaction> else { return [] }
        return transactions.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    var displayColor: String {
        colorHex ?? "007AFF"
    }
}

// MARK: - Remote Changes Notification

extension Notification.Name {
    /// Posted when remote changes are received from CloudKit
    static let didReceiveRemoteChanges = Notification.Name("didReceiveRemoteChanges")
}
