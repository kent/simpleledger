import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var currencyManager = CurrencyManager.shared

    @State private var showingSharingSheet = false
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            List {
                // Currency Section
                Section {
                    Picker("Currency", selection: Binding(
                        get: { currencyManager.currencyCode },
                        set: { currencyManager.setCurrency($0, in: viewContext) }
                    )) {
                        ForEach(CurrencyManager.supportedCurrencies, id: \.code) { currency in
                            HStack {
                                Text(currency.symbol)
                                    .frame(width: 30, alignment: .leading)
                                Text(currency.name)
                            }
                            .tag(currency.code)
                        }
                    }
                } header: {
                    Text("Currency")
                } footer: {
                    Text("All balances will be displayed in this currency.")
                }

                // Sharing Section
                Section {
                    Button {
                        showingSharingSheet = true
                    } label: {
                        Label("Family Sharing", systemImage: "person.2.fill")
                    }
                } header: {
                    Text("Sharing")
                } footer: {
                    Text("Share your data with family members so everyone can track the kids' money together.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://apple.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("About")
                }

                // Sync Status
                Section {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundStyle(.blue)
                        Text("iCloud Sync")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("Sync")
                } footer: {
                    Text("Your data automatically syncs across all your devices signed into the same iCloud account.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSharingSheet) {
                ShareConfigurationView(persistenceController: persistenceController)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PersistenceController.preview)
}
