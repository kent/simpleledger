import Foundation
import CoreData

@MainActor
final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()

    @Published var currencyCode: String = "USD"

    private init() {
        loadCurrency()
    }

    func loadCurrency() {
        // Load from UserDefaults for quick access
        // The AppSettings entity is used for CloudKit sync
        if let saved = UserDefaults.standard.string(forKey: "currencyCode") {
            currencyCode = saved
        }
    }

    func setCurrency(_ code: String, in context: NSManagedObjectContext) {
        currencyCode = code
        UserDefaults.standard.set(code, forKey: "currencyCode")

        // Also save to Core Data for CloudKit sync
        let request = NSFetchRequest<AppSettings>(entityName: "AppSettings")
        request.fetchLimit = 1

        do {
            if let settings = try context.fetch(request).first {
                settings.currencyCode = code
            } else {
                let settings = AppSettings(context: context)
                settings.id = UUID()
                settings.currencyCode = code
            }
            try context.save()
        } catch {
            print("Failed to save currency setting: \(error)")
        }
    }

    static let supportedCurrencies: [(code: String, name: String, symbol: String)] = [
        ("USD", "US Dollar", "$"),
        ("EUR", "Euro", "€"),
        ("GBP", "British Pound", "£"),
        ("CAD", "Canadian Dollar", "C$"),
        ("AUD", "Australian Dollar", "A$"),
        ("JPY", "Japanese Yen", "¥"),
        ("CHF", "Swiss Franc", "CHF"),
        ("CNY", "Chinese Yuan", "¥"),
        ("INR", "Indian Rupee", "₹"),
        ("MXN", "Mexican Peso", "$"),
        ("BRL", "Brazilian Real", "R$"),
        ("KRW", "South Korean Won", "₩"),
        ("SEK", "Swedish Krona", "kr"),
        ("NOK", "Norwegian Krone", "kr"),
        ("DKK", "Danish Krone", "kr"),
        ("NZD", "New Zealand Dollar", "NZ$"),
        ("SGD", "Singapore Dollar", "S$"),
        ("HKD", "Hong Kong Dollar", "HK$"),
    ]
}
