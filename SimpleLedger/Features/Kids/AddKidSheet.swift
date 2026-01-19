import SwiftUI
import CoreData

struct AddKidSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController

    @State private var name = ""
    @State private var selectedEmoji = "👧"
    @State private var selectedColor = "007AFF"

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

                Section {
                    // Preview
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: selectedColor).opacity(0.2))
                                .frame(width: 50, height: 50)

                            Text(selectedEmoji)
                                .font(.title)
                        }

                        Text(name.isEmpty ? "Name" : name)
                            .font(.headline)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)

                        Spacer()

                        Text("$0.00")
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addKid()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addKid() {
        let kid = Kid(context: viewContext)
        kid.id = UUID()
        kid.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        kid.avatarEmoji = selectedEmoji
        kid.colorHex = selectedColor
        kid.createdAt = Date()

        persistenceController.save()
        dismiss()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    AddKidSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PersistenceController.preview)
}
