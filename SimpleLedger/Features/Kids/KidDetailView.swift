import SwiftUI
import CoreData
import StoreKit

struct KidDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var persistenceController: PersistenceController
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @ObservedObject var kid: Kid
    @StateObject private var currencyManager = CurrencyManager.shared

    @State private var showingEditSheet = false
    @State private var showingHistory = false
    @State private var showingCustomAmount = false
    @State private var showingAddAmount = false
    @State private var showingSubtractAmount = false
    @State private var showingShareSheet = false
    @State private var showingStopSharingAlert = false
    @State private var showingLeaveShareAlert = false
    @State private var balanceScale: CGFloat = 1.0
    @State private var lastChange: Decimal = 0
    @State private var showChangeIndicator = false
    @State private var showConfetti = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

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

                // Large Add/Subtract buttons
                largeActionButtons

                // Quick Action Buttons - the main event!
                quickActionGrid

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
        .sheet(isPresented: $showingAddAmount) {
            QuickTransactionView(kid: kid, initialIsAdding: true)
        }
        .sheet(isPresented: $showingSubtractAmount) {
            QuickTransactionView(kid: kid, initialIsAdding: false)
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
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveRemoteChanges)) { _ in
            // Check if this kid was deleted remotely
            if kid.isFault || kid.isDeleted || kid.managedObjectContext == nil {
                dismiss()
            }
        }
        .onChange(of: kid.isFault) { _, isFault in
            // Dismiss if the kid becomes a fault (deleted remotely)
            if isFault {
                dismiss()
            }
        }
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
                await MainActor.run {
                    errorMessage = "Failed to stop sharing: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
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
                await MainActor.run {
                    errorMessage = "Failed to stop viewing: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
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

    // MARK: - Large Action Buttons

    private var largeActionButtons: some View {
        HStack(spacing: 16) {
            // Add button
            Button {
                showingAddAmount = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                    Text("Add")
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.green.opacity(0.15))
                .foregroundStyle(.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                )
            }

            // Subtract button
            Button {
                showingSubtractAmount = true
            } label: {
                HStack {
                    Image(systemName: "minus")
                        .font(.system(size: 28, weight: .bold))
                    Text("Spend")
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.red.opacity(0.15))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                )
            }
        }
        .padding(.horizontal)
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
        transaction.createdByName = cloudKitManager.currentUserName ?? "Me"
        transaction.kid = kid

        persistenceController.save()

        // Track transaction count and request review after 3rd transaction
        let transactionCountKey = "totalTransactionCount"
        let count = UserDefaults.standard.integer(forKey: transactionCountKey) + 1
        UserDefaults.standard.set(count, forKey: transactionCountKey)

        if count == 3 {
            // Request review after a brief delay to let the animation finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                requestReview()
            }
        }
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
