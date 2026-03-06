import CloudKit
import CoreData
import SwiftUI
import UIKit

enum CloudKitErrorFormatter {
    static func message(for error: Error) -> String {
        if isMissingProductionSchemaError(error) {
            return "iCloud sharing is not ready in the production CloudKit environment yet. Deploy the Munnies CloudKit schema to production, then try again."
        }

        if let ckError = error as? CKError {
            switch ckError.code {
            case .notAuthenticated:
                return "Sign in to iCloud on this device to use sharing."
            case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited:
                return "CloudKit is temporarily unavailable. Try again in a moment."
            default:
                break
            }
        }

        return error.localizedDescription
    }

    private static func isMissingProductionSchemaError(_ error: Error) -> Bool {
        let details = flattenedErrorDetails(from: error).lowercased()
        return details.contains("cannot create new type")
            || (details.contains("production schema") && details.contains("cd_"))
    }

    private static func flattenedErrorDetails(from error: Error) -> String {
        var messages: [String] = []
        var queue: [Any] = [error]

        while let current = queue.popLast() {
            switch current {
            case let nestedError as Error:
                let nsError = nestedError as NSError
                messages.append(nsError.domain)
                messages.append(String(nsError.code))
                messages.append(nsError.localizedDescription)

                if let failureReason = nsError.localizedFailureReason {
                    messages.append(failureReason)
                }

                if let recoverySuggestion = nsError.localizedRecoverySuggestion {
                    messages.append(recoverySuggestion)
                }

                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] {
                    queue.append(underlyingError)
                }

                if let detailedErrors = nsError.userInfo[NSDetailedErrorsKey] as? [Any] {
                    queue.append(contentsOf: detailedErrors)
                }

                if let partialErrors = nsError.userInfo[CKPartialErrorsByItemIDKey] as? [AnyHashable: Any] {
                    queue.append(contentsOf: partialErrors.values)
                }

                for value in nsError.userInfo.values where value is String {
                    queue.append(value)
                }
            case let string as String:
                messages.append(string)
            default:
                messages.append(String(describing: current))
            }
        }

        return messages.joined(separator: " ")
    }
}

@MainActor
final class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    @Published var isSignedIntoiCloud = false
    @Published var permissionStatus: Bool = false
    @Published var error: String?
    @Published var currentUserName: String?

    private let container: CKContainer

    init() {
        container = CKContainer(identifier: "iCloud.com.ewakened.munnies")
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

@MainActor
private final class CloudSharingHostViewController: UIViewController {
    var makeSharingController: (@MainActor () async throws -> UICloudSharingController)?
    var onFinish: (() -> Void)?
    var onError: ((Error) -> Void)?

    private var presentationTask: Task<Void, Never>?
    private var hasStartedPreparing = false
    private var hasPresentedSharingController = false
    private var hasFinished = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if hasPresentedSharingController && presentedViewController == nil {
            finish()
            return
        }

        guard !hasStartedPreparing else { return }
        hasStartedPreparing = true

        presentationTask = Task { [weak self] in
            guard let self else { return }

            do {
                guard let makeSharingController else {
                    finish()
                    return
                }

                let controller = try await makeSharingController()

                guard !Task.isCancelled else { return }
                guard view.window != nil, presentedViewController == nil else {
                    finish()
                    return
                }

                hasPresentedSharingController = true
                present(controller, animated: true)
            } catch is CancellationError {
                finish()
            } catch {
                onError?(error)
                finish()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed || navigationController?.isBeingDismissed == true {
            presentationTask?.cancel()
        }
    }

    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        onFinish?()
    }
}

struct KidCloudSharingView: UIViewControllerRepresentable {
    let kid: Kid
    let persistenceController: PersistenceController
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let hostController = CloudSharingHostViewController()
        hostController.makeSharingController = {
            let share = try await persistenceController.shareKid(kid)
            let container = CKContainer(identifier: "iCloud.com.ewakened.munnies")
            let controller = UICloudSharingController(share: share, container: container)
            controller.modalPresentationStyle = .formSheet
            controller.availablePermissions = [.allowPrivate, .allowReadOnly, .allowReadWrite]
            controller.delegate = context.coordinator
            return controller
        }
        hostController.onFinish = {
            context.coordinator.dismissShareSheet()
        }
        hostController.onError = { error in
            context.coordinator.handleShareError(error)
        }
        return hostController
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

        func dismissShareSheet() {
            parent.isPresented = false
        }

        func handleShareError(_ error: Error) {
            print("Failed to create share: \(error)")
            NotificationCenter.default.post(
                name: .cloudSharingFailed,
                object: nil,
                userInfo: ["error": CloudKitErrorFormatter.message(for: error)]
            )
            parent.isPresented = false
        }

        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            // Share was saved successfully
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            handleShareError(error)
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            dismissShareSheet()
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "\(parent.kid.name ?? "Child")'s Account"
        }

        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            nil
        }
    }
}

extension Notification.Name {
    static let cloudSharingFailed = Notification.Name("cloudSharingFailed")
}
