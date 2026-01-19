import SwiftUI
import CoreData

struct KidDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @ObservedObject var kid: Kid
    @StateObject private var currencyManager = CurrencyManager.shared

    @State private var showingEditSheet = false
    @State private var showingHistory = false
    @State private var showingCustomAmount = false
    @State private var showingShareSheet = false
    @State private var showingStopSharingAlert = false
    @State private var showingLeaveShareAlert = false
    @State private var balanceScale: CGFloat = 1.0
    @State private var lastChange: Decimal = 0
    @State private var showChangeIndicator = false
    @State private var showConfetti = false

    private let quickAmounts: [Decimal] = [1, 5, 10, 20]

    private var shareStatus: PersistenceController.KidShareStatus {
        persistenceController.shareStatus(for: kid)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Shared banner for participants
                if shareStatus.isShared && !shareStatus.isOwner {
                    sharedBanner
                }

                // Header with avatar
                avatarHeader

                // Big Balance Display
                balanceCard

                // Quick Action Buttons - the main event!
                quickActionGrid

                // Custom amount button
                Button {
                    showingCustomAmount = true
                } label: {
                    Label("Custom Amount", systemImage: "number.square")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Recent activity peek
                recentActivitySection
            }
            .padding(.vertical)
        }
        .navigationTitle(kid.name ?? "Child")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    if cloudKitManager.isSignedIntoiCloud {
                        Divider()

                        if shareStatus.isOwner {
                            if shareStatus.isShared {
                                Button {
                                    showingShareSheet = true
                                } label: {
                                    Label("Manage Sharing", systemImage: "person.2")
                                }

                                Button(role: .destructive) {
                                    showingStopSharingAlert = true
                                } label: {
                                    Label("Stop Sharing", systemImage: "person.badge.minus")
                                }
                            } else {
                                Button {
                                    showingShareSheet = true
                                } label: {
                                    Label("Share Ledger", systemImage: "person.badge.plus")
                                }
                            }
                        } else if shareStatus.isShared {
                            Button(role: .destructive) {
                                showingLeaveShareAlert = true
                            } label: {
                                Label("Stop Viewing", systemImage: "eye.slash")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditKidSheet(kid: kid)
        }
        .sheet(isPresented: $showingCustomAmount) {
            QuickTransactionView(kid: kid)
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                TransactionListView(kid: kid)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingHistory = false }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            KidCloudSharingView(
                kid: kid,
                persistenceController: persistenceController,
                isPresented: $showingShareSheet
            )
        }
        .alert("Stop Sharing?", isPresented: $showingStopSharingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Stop Sharing", role: .destructive) {
                stopSharing()
            }
        } message: {
            Text("Others will no longer be able to view or edit \(kid.name ?? "this ledger")'s transactions.")
        }
        .alert("Stop Viewing?", isPresented: $showingLeaveShareAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Stop Viewing", role: .destructive) {
                leaveShare()
            }
        } message: {
            Text("You will no longer be able to view \(kid.name ?? "this ledger")'s transactions.")
        }
        .confetti(isShowing: $showConfetti)
    }

    // MARK: - Shared Banner

    private var sharedBanner: some View {
        HStack {
            Image(systemName: "person.2.fill")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Shared Ledger")
                    .font(.subheadline.bold())
                if let ownerName = shareStatus.ownerName {
                    Text("Shared by \(ownerName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func stopSharing() {
        Task {
            do {
                try await persistenceController.stopSharing(kid: kid)
            } catch {
                print("Failed to stop sharing: \(error)")
            }
        }
    }

    private func leaveShare() {
        Task {
            do {
                try await persistenceController.leaveShare(for: kid)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to leave share: \(error)")
            }
        }
    }

    // MARK: - Avatar Header

    private var avatarHeader: some View {
        ZStack {
            Circle()
                .fill(Color(hex: kid.displayColor).opacity(0.2))
                .frame(width: 100, height: 100)

            Text(kid.avatarEmoji ?? "👤")
                .font(.system(size: 50))
        }
        .padding(.top, 8)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                Text(kid.balance, format: .currency(code: currencyManager.currencyCode))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(kid.balance >= 0 ? .primary : .red)
                    .scaleEffect(balanceScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: balanceScale)

                // Change indicator
                if showChangeIndicator {
                    Text(lastChange >= 0 ? "+\(lastChange as NSDecimalNumber)" : "\(lastChange as NSDecimalNumber)")
                        .font(.title2.bold())
                        .foregroundColor(lastChange >= 0 ? .green : .red)
                        .offset(y: -50)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
        }
        .padding()
    }

    // MARK: - Quick Action Grid

    private var quickActionGrid: some View {
        VStack(spacing: 16) {
            // Add money row
            HStack(spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAddButton(
                        amount: amount,
                        currencyCode: currencyManager.currencyCode,
                        isAdd: true
                    ) {
                        addMoney(amount)
                    }
                }
            }

            // Remove money row
            HStack(spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAddButton(
                        amount: amount,
                        currencyCode: currencyManager.currencyCode,
                        isAdd: false
                    ) {
                        removeMoney(amount)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                if !kid.sortedTransactions.isEmpty {
                    Button("See All") {
                        showingHistory = true
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)

            if kid.sortedTransactions.isEmpty {
                Text("No transactions yet.\nTap + or − above to get started!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(kid.sortedTransactions.prefix(3), id: \.id) { transaction in
                        TransactionRowView(transaction: transaction)
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                        if transaction.id != kid.sortedTransactions.prefix(3).last?.id {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func addMoney(_ amount: Decimal) {
        createTransaction(amount: amount)
        animateChange(amount)
    }

    private func removeMoney(_ amount: Decimal) {
        createTransaction(amount: -amount)
        animateChange(-amount)
    }

    private func createTransaction(amount: Decimal) {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.createdAt = Date()
        transaction.kid = kid

        persistenceController.save()
    }

    private func animateChange(_ amount: Decimal) {
        // Haptic - stronger for deposits
        let generator = UIImpactFeedbackGenerator(style: amount > 0 ? .medium : .light)
        generator.impactOccurred()

        // Confetti for deposits of $10 or more!
        if amount >= 10 {
            showConfetti = true
        }

        // Visual feedback
        lastChange = amount
        withAnimation(.spring(response: 0.2)) {
            showChangeIndicator = true
            balanceScale = 1.15
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3)) {
                balanceScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showChangeIndicator = false
            }
        }
    }
}

// MARK: - Quick Add Button

struct QuickAddButton: View {
    let amount: Decimal
    let currencyCode: String
    let isAdd: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Text(isAdd ? "+" : "−")
                    .font(.system(size: 24, weight: .bold))

                Text(amount, format: .currency(code: currencyCode))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isAdd ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isAdd ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 2)
            )
            .foregroundStyle(isAdd ? .green : .red)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .pressAction {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Press Action Modifier

struct PressActionModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActionModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Edit Kid Sheet

struct EditKidSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    @ObservedObject var kid: Kid

    @State private var name: String = ""
    @State private var selectedEmoji: String = "👧"
    @State private var selectedColor: String = "007AFF"

    private let emojis = ["👧", "👦", "👶", "🧒", "👸", "🤴", "🧑", "👱", "🐱", "🐶", "🦊", "🐰"]

    private let colors: [(name: String, hex: String)] = [
        ("Blue", "007AFF"),
        ("Red", "FF6B6B"),
        ("Green", "4ECDC4"),
        ("Purple", "9B59B6"),
        ("Orange", "F39C12"),
        ("Pink", "E91E63"),
        ("Teal", "1ABC9C"),
        ("Indigo", "3F51B5"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Child's name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Avatar") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.largeTitle)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : Color.clear)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedEmoji == emoji ? Color.accentColor : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.hex) { color in
                            Button {
                                selectedColor = color.hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color.hex ? 3 : 0)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .opacity(selectedColor == color.hex ? 1 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                name = kid.name ?? ""
                selectedEmoji = kid.avatarEmoji ?? "👧"
                selectedColor = kid.colorHex ?? "007AFF"
            }
        }
    }

    private func saveChanges() {
        kid.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        kid.avatarEmoji = selectedEmoji
        kid.colorHex = selectedColor

        persistenceController.save()
        dismiss()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    NavigationStack {
        KidDetailView(kid: {
            let context = PersistenceController.preview.container.viewContext
            let kid = Kid(context: context)
            kid.id = UUID()
            kid.name = "Emma"
            kid.avatarEmoji = "👧"
            kid.colorHex = "FF6B6B"
            kid.createdAt = Date()

            let t = Transaction(context: context)
            t.id = UUID()
            t.amount = NSDecimalNumber(value: 25.0)
            t.note = "Birthday money"
            t.createdAt = Date()
            t.kid = kid

            return kid
        }())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .environmentObject(PersistenceController.preview)
}
