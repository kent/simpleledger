import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register for remote notifications to receive CloudKit changes
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // CloudKit handles this automatically
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Handle CloudKit notifications
        completionHandler(.newData)
    }

    // MARK: - Handle Share Acceptance

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

// MARK: - Scene Delegate for Share Acceptance

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Check if launching from a CloudKit share URL
        if let cloudKitShareMetadata = connectionOptions.cloudKitShareMetadata {
            Task {
                await acceptShare(metadata: cloudKitShareMetadata)
            }
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        Task {
            await acceptShare(metadata: cloudKitShareMetadata)
        }
    }

    @MainActor
    private func acceptShare(metadata: CKShare.Metadata) async {
        let persistenceController = PersistenceController.shared

        // Wait for stores to be loaded before attempting to accept share
        let storesReady = await persistenceController.waitForStoresLoaded(timeout: 15.0)

        guard storesReady else {
            print("Stores failed to load in time for share acceptance")
            NotificationCenter.default.post(
                name: .shareAcceptanceFailed,
                object: nil,
                userInfo: ["error": "Stores not ready. Please try again."]
            )
            return
        }

        guard let sharedStore = persistenceController.sharedPersistentStore else {
            print("Shared store not available after loading")
            NotificationCenter.default.post(
                name: .shareAcceptanceFailed,
                object: nil,
                userInfo: ["error": "Unable to access shared data store."]
            )
            return
        }

        do {
            try await persistenceController.container.acceptShareInvitations(
                from: [metadata],
                into: sharedStore
            )
            // Post notification to refresh UI
            NotificationCenter.default.post(name: .didAcceptCloudKitShare, object: nil)
            print("Successfully accepted share invitation")
        } catch {
            print("Failed to accept share: \(error)")
            NotificationCenter.default.post(
                name: .shareAcceptanceFailed,
                object: nil,
                userInfo: ["error": error.localizedDescription]
            )
        }
    }
}

// MARK: - Share Acceptance Notification

extension Notification.Name {
    static let shareAcceptanceFailed = Notification.Name("shareAcceptanceFailed")
}
