import CloudKit
import CoreData
import SwiftUI
import UIKit

@MainActor
final class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    @Published var isSignedIntoiCloud = false
    @Published var permissionStatus: Bool = false
    @Published var error: String?

    private let container: CKContainer

    init() {
        container = CKContainer(identifier: "iCloud.com.simpleledger.app")
        Task {
            await checkiCloudStatus()
        }
    }

    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            isSignedIntoiCloud = status == .available
            if status != .available {
                error = "iCloud account not available. Please sign in to iCloud in Settings."
            }
        } catch {
            self.error = "Error checking iCloud status: \(error.localizedDescription)"
            isSignedIntoiCloud = false
        }
    }

    // MARK: - Sharing

    /// Creates a CKShare for a managed object to share with family
    func createShare(
        for object: NSManagedObject,
        in persistenceController: PersistenceController
    ) async throws -> CKShare {
        let (_, share, _) = try await persistenceController.container.share(
            [object],
            to: nil
        )

        share[CKShare.SystemFieldKey.title] = "SimpleLedger Family Data"

        return share
    }

    /// Accepts a share from a URL (called when user taps a sharing link)
    func acceptShare(from url: URL, into persistenceController: PersistenceController) async throws {
        guard let sharedStore = persistenceController.sharedPersistentStore else {
            throw NSError(domain: "CloudKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Shared store not available"])
        }
        let metadata = try await container.shareMetadata(for: url)
        try await persistenceController.container.acceptShareInvitations(
            from: [metadata],
            into: sharedStore
        )
    }
}

// MARK: - Kid-Specific Cloud Sharing View

struct KidCloudSharingView: UIViewControllerRepresentable {
    let kid: Kid
    let persistenceController: PersistenceController
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        // Create a wrapper to handle async share creation
        let wrapper = UIViewController()
        wrapper.view.backgroundColor = .clear

        Task { @MainActor in
            do {
                let share = try await persistenceController.shareKid(kid)
                let container = CKContainer(identifier: "iCloud.com.simpleledger.app")

                let controller = UICloudSharingController(share: share, container: container)
                controller.modalPresentationStyle = .formSheet
                controller.delegate = context.coordinator

                // Present the sharing controller
                wrapper.present(controller, animated: true)
            } catch {
                print("Failed to create share: \(error)")
                isPresented = false
            }
        }

        return wrapper
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let parent: KidCloudSharingView

        init(_ parent: KidCloudSharingView) {
            self.parent = parent
        }

        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            // Share was saved successfully
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Failed to save share: \(error)")
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            // User stopped sharing
            parent.isPresented = false
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "\(parent.kid.name ?? "Child")'s Ledger"
        }

        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            nil
        }
    }
}

// MARK: - Legacy UICloudSharingController Wrapper (for existing shares)

struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let persistenceController: PersistenceController

    func makeUIViewController(context: Context) -> UICloudSharingController {
        share[CKShare.SystemFieldKey.title] = "SimpleLedger Family Data"

        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .formSheet
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let parent: CloudSharingView

        init(_ parent: CloudSharingView) {
            self.parent = parent
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Failed to save share: \(error)")
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "SimpleLedger Family Data"
        }

        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            nil
        }
    }
}

// MARK: - Share Configuration View

struct ShareConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var persistenceController: PersistenceController
    @StateObject private var cloudKitManager = CloudKitManager.shared

    @State private var existingShare: CKShare?
    @State private var isCreatingShare = false
    @State private var showSharingSheet = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if !cloudKitManager.isSignedIntoiCloud {
                        Label {
                            Text("Sign in to iCloud to share with family")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                        }
                    } else if let share = existingShare {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Shared with Family")
                                Text("\(share.participants.count) participant(s)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }

                        Button("Manage Sharing...") {
                            showSharingSheet = true
                        }
                    } else {
                        Button {
                            Task {
                                await createAndShowShare()
                            }
                        } label: {
                            Label("Share with Family", systemImage: "person.badge.plus")
                        }
                        .disabled(isCreatingShare)
                    }
                } header: {
                    Text("Family Sharing")
                } footer: {
                    Text("Share your SimpleLedger data with your spouse or family members. They'll be able to view and edit all kids' accounts.")
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSharingSheet) {
                if let share = existingShare {
                    CloudSharingView(
                        share: share,
                        container: CKContainer(identifier: "iCloud.com.simpleledger.app"),
                        persistenceController: persistenceController
                    )
                }
            }
            .task {
                await loadExistingShare()
            }
        }
    }

    private func loadExistingShare() async {
        do {
            let shares = try persistenceController.fetchShares()
            existingShare = shares.first
        } catch {
            errorMessage = "Failed to load sharing status: \(error.localizedDescription)"
        }
    }

    private func createAndShowShare() async {
        isCreatingShare = true
        errorMessage = nil

        do {
            // We need a root object to share - fetch or create a settings object
            let context = persistenceController.container.viewContext
            let request = NSFetchRequest<AppSettings>(entityName: "AppSettings")
            request.fetchLimit = 1

            var settings: AppSettings
            if let existingSettings = try context.fetch(request).first {
                settings = existingSettings
            } else {
                settings = AppSettings(context: context)
                settings.id = UUID()
                settings.currencyCode = "USD"
                try context.save()
            }

            existingShare = try await cloudKitManager.createShare(
                for: settings,
                in: persistenceController
            )
            showSharingSheet = true
        } catch {
            errorMessage = "Failed to create share: \(error.localizedDescription)"
        }

        isCreatingShare = false
    }
}
