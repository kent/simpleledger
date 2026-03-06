import SwiftUI
import CloudKit

private struct AppLaunchOptions {
    enum ScreenshotRoute: String {
        case dashboard
        case ledger
        case addMoney = "add-money"
        case history
    }

    let seedSampleData: Bool
    let resetSampleData: Bool
    let initializeCloudKitSchema: Bool
    let skipOnboarding: Bool
    let screenshotRoute: ScreenshotRoute?

    static let current: AppLaunchOptions = {
        let arguments = ProcessInfo.processInfo.arguments

        func contains(_ flag: String) -> Bool {
            arguments.contains(flag)
        }

        func value(after flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
                return nil
            }
            return arguments[index + 1]
        }

        return AppLaunchOptions(
            seedSampleData: contains("-seed-sample-data") || contains("-reset-sample-data") || contains("-screenshot-mode"),
            resetSampleData: contains("-reset-sample-data") || contains("-screenshot-mode"),
            initializeCloudKitSchema: contains("-initialize-cloudkit-schema"),
            skipOnboarding: contains("-skip-onboarding") || contains("-screenshot-mode"),
            screenshotRoute: value(after: "-screenshot-route").flatMap(ScreenshotRoute.init(rawValue:))
        )
    }()
}

@main
struct MunniesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    let persistenceController = PersistenceController.shared
    private let launchOptions = AppLaunchOptions.current

    private var shouldShowMainContent: Bool {
        hasSeenOnboarding || launchOptions.skipOnboarding || launchOptions.screenshotRoute != nil
    }

    var body: some Scene {
        WindowGroup {
            if shouldShowMainContent {
                MainAppContentView(launchOptions: launchOptions)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(persistenceController)
            } else {
                WelcomeView()
            }
        }
    }
}

private struct MainAppContentView: View {
    @EnvironmentObject private var persistenceController: PersistenceController
    @Environment(\.managedObjectContext) private var viewContext

    let launchOptions: AppLaunchOptions

    @State private var isPrepared = false
    @State private var preparationError: String?
    @State private var preparationMessage: String?

    var body: some View {
        Group {
            if let preparationError {
                ContentUnavailableView("Unable to Load Data", systemImage: "exclamationmark.triangle.fill", description: Text(preparationError))
            } else if let preparationMessage {
                ContentUnavailableView(preparationMessage, systemImage: "icloud.fill")
            } else if isPrepared {
                if let route = launchOptions.screenshotRoute {
                    ScreenshotSceneView(route: route)
                } else {
                    KidsListView()
                }
            } else {
                ProgressView("Preparing Munnies…")
                    .task {
                        await prepareAppDataIfNeeded()
                    }
            }
        }
    }

    @MainActor
    private func prepareAppDataIfNeeded() async {
        guard !isPrepared else { return }

        let storesReady = await persistenceController.waitForStoresLoaded(timeout: 15.0)
        guard storesReady else {
            preparationError = persistenceController.storeLoadError?.localizedDescription ?? "Persistent stores were not ready in time."
            return
        }

        if launchOptions.initializeCloudKitSchema {
            do {
                try persistenceController.initializeCloudKitSchema()
                preparationMessage = "CloudKit schema initialized."
            } catch {
                preparationError = error.localizedDescription
            }
            return
        }

        if launchOptions.resetSampleData {
            persistenceController.resetAndSeedSampleData()
        } else if launchOptions.seedSampleData {
            persistenceController.seedSampleDataIfNeeded()
        }

        isPrepared = true
    }
}

private struct ScreenshotSceneView: View {
    @EnvironmentObject private var persistenceController: PersistenceController

    let route: AppLaunchOptions.ScreenshotRoute

    private var featuredKid: Kid? {
        let allKids = persistenceController.fetchAllKids()
        return (allKids.privateKids + allKids.sharedKids).first { $0.name == "Emma" } ?? (allKids.privateKids + allKids.sharedKids).first
    }

    var body: some View {
        Group {
            switch route {
            case .dashboard:
                KidsListView()
            case .ledger:
                if let featuredKid {
                    NavigationStack {
                        KidDetailView(kid: featuredKid)
                    }
                } else {
                    ContentUnavailableView("No Demo Data", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            case .addMoney:
                if let featuredKid {
                    QuickTransactionView(
                        kid: featuredKid,
                        initialIsAdding: true,
                        initialDisplayValue: "20",
                        initialNote: "Tooth fairy"
                    )
                } else {
                    ContentUnavailableView("No Demo Data", systemImage: "dollarsign.circle")
                }
            case .history:
                if let featuredKid {
                    NavigationStack {
                        TransactionListView(kid: featuredKid)
                    }
                } else {
                    ContentUnavailableView("No Demo Data", systemImage: "clock.badge.exclamationmark")
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
