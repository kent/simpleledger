import Foundation
import CoreData

@MainActor
final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()

    @Published var currencyCode: String = "USD"
    private static let genericCurrencyCodes: Set<String> = Set(supportedCurrencies.map(\.code))

    private init() {
        loadCurrency()
    }

    func loadCurrency() {
        // Load from UserDefaults for quick access
        // The AppSettings entity is used for CloudKit sync
        if let saved = UserDefaults.standard.string(forKey: "currencyCode") {
            currencyCode = Self.normalizedCurrencyCode(saved)
        }
    }

    func setCurrency(_ code: String, in context: NSManagedObjectContext) {
        let normalizedCode = Self.normalizedCurrencyCode(code)
        currencyCode = normalizedCode
        UserDefaults.standard.set(normalizedCode, forKey: "currencyCode")

        // Also save to Core Data for CloudKit sync
        let request = NSFetchRequest<AppSettings>(entityName: "AppSettings")
        request.fetchLimit = 1

        do {
            if let settings = try context.fetch(request).first {
                settings.currencyCode = normalizedCode
            } else {
                let settings = AppSettings(context: context)
                settings.id = UUID()
                settings.currencyCode = normalizedCode
            }
            try context.save()
        } catch {
            print("Failed to save currency setting: \(error)")
        }
    }

    static let supportedCurrencies: [(code: String, name: String, symbol: String)] = [
        ("USD", "Dollar", "$"),
        ("EUR", "Euro", "€"),
        ("GBP", "Pound", "£"),
        ("JPY", "Yen", "¥"),
        ("CNY", "Yuan", "¥"),
        ("CHF", "Franc", "CHF"),
        ("INR", "Rupee", "₹"),
        ("MXN", "Peso", "$"),
        ("BRL", "Real", "R$"),
        ("KRW", "Won", "₩"),
        ("SEK", "Krona", "kr"),
    ]

    private static func normalizedCurrencyCode(_ code: String) -> String {
        if genericCurrencyCodes.contains(code) {
            return code
        }

        switch code {
        case "CAD", "AUD", "NZD", "SGD", "HKD":
            return "USD"
        case "NOK", "DKK":
            return "SEK"
        default:
            return "USD"
        }
    }
}
