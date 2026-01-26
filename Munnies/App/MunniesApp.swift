import SwiftUI
import CloudKit

@main
struct MunniesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                KidsListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(persistenceController)
            } else {
                WelcomeView()
            }
        }
    }
}
