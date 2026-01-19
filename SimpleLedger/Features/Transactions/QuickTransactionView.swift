import SwiftUI
import CoreData

struct QuickTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    @ObservedObject var kid: Kid
    @StateObject private var currencyManager = CurrencyManager.shared

    var initialIsAdding: Bool? = nil

    @State private var displayValue = "0"
    @State private var isAdding = true
    @State private var note = ""
    @State private var showingNoteField = false

    private var amount: Decimal {
        Decimal(string: displayValue) ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode toggle
                Picker("Type", selection: $isAdding) {
                    Text("Add").tag(true)
                    Text("Spend").tag(false)
                }
                .pickerStyle(.segmented)
                .padding()

                Spacer()

                // Amount display
                VStack(spacing: 8) {
                    Text(isAdding ? "Adding" : "Spending")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(isAdding ? "+" : "−")
                            .font(.system(size: 36, weight: .medium))
                        Text(currencySymbol)
                            .font(.system(size: 36, weight: .medium))
                        Text(displayValue)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(isAdding ? .green : .red)
                    .animation(.none, value: displayValue)
                }

                Spacer()

                // Note field (optional, toggleable)
                if showingNoteField {
                    HStack {
                        TextField("What's this for?", text: $note)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            withAnimation { showingNoteField = false }
                            note = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else {
                    Button {
                        withAnimation { showingNoteField = true }
                    } label: {
                        Label("Add note", systemImage: "square.and.pencil")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }

                // Number pad
                numberPad

                // Confirm button
                Button {
                    saveTransaction()
                } label: {
                    Text(isAdding ? "Add Money" : "Spend Money")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(amount > 0 ? (isAdding ? Color.green : Color.red) : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(amount <= 0)
                .padding()
            }
            .navigationTitle("Custom Amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .onAppear {
            if let initial = initialIsAdding {
                isAdding = initial
            }
        }
    }

    private var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyManager.currencyCode
        return formatter.currencySymbol ?? "$"
    }

    // MARK: - Number Pad

    private var numberPad: some View {
        VStack(spacing: 12) {
            ForEach(numberRows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        NumberPadKey(key: key) {
                            handleKeyPress(key)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private let numberRows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    private func handleKeyPress(_ key: String) {
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        switch key {
        case "⌫":
            if displayValue.count > 1 {
                displayValue.removeLast()
            } else {
                displayValue = "0"
            }
        case ".":
            if !displayValue.contains(".") {
                displayValue += "."
            }
        default:
            // Limit to 2 decimal places
            if let dotIndex = displayValue.firstIndex(of: ".") {
                let decimals = displayValue.distance(from: dotIndex, to: displayValue.endIndex) - 1
                if decimals >= 2 { return }
            }

            // Limit total length
            if displayValue.count >= 8 { return }

            if displayValue == "0" && key != "." {
                displayValue = key
            } else {
                displayValue += key
            }
        }
    }

    // MARK: - Save

    private func saveTransaction() {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(decimal: isAdding ? amount : -amount)
        transaction.note = note.isEmpty ? nil : note
        transaction.createdAt = Date()
        transaction.kid = kid

        persistenceController.save()

        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}

// MARK: - Number Pad Key

struct NumberPadKey: View {
    let key: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if key == "⌫" {
                    Image(systemName: "delete.left")
                        .font(.title2)
                } else {
                    Text(key)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .foregroundStyle(.primary)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .pressAction {
            withAnimation(.easeInOut(duration: 0.05)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.05)) {
                isPressed = false
            }
        }
    }
}

#Preview {
    QuickTransactionView(kid: {
        let context = PersistenceController.preview.container.viewContext
        let kid = Kid(context: context)
        kid.id = UUID()
        kid.name = "Emma"
        kid.avatarEmoji = "👧"
        kid.colorHex = "FF6B6B"
        return kid
    }())
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(PersistenceController.preview)
}
