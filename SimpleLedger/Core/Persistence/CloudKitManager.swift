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
    @Published var currentUserName: String?

    private let container: CKContainer

    init() {
        container = CKContainer(identifier: "iCloud.com.simpleledger.app")
        Task {
            await checkiCloudStatus()
            await fetchCurrentUserName()
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

    func fetchCurrentUserName() async {
        do {
            let userID = try await container.userRecordID()
            let userIdentity = try await container.userIdentity(forUserRecordID: userID)

            if let nameComponents = userIdentity?.nameComponents {
                currentUserName = PersonNameComponentsFormatter.localizedString(from: nameComponents, style: .short)
            } else {
                // Fallback to device name if CloudKit name not available
                currentUserName = UIDevice.current.name
            }
        } catch {
            print("Failed to fetch user name: \(error)")
            // Fallback to device name
            currentUserName = UIDevice.current.name
        }
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

