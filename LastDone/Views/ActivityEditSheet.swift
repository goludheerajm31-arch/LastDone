import SwiftUI

/// Native iOS sheet for creating or editing an activity.
struct ActivityEditSheet: View {
    enum Mode {
        case create
        case edit(Activity)
    }

    let mode: Mode

    @EnvironmentObject private var store: ActivityStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var lastCompletedAt: Date = Date()
    @State private var isShowingDeleteConfirmation = false
    @FocusState private var isNameFocused: Bool

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            _name = State(initialValue: "")
            _lastCompletedAt = State(initialValue: Date())
        case .edit(let activity):
            _name = State(initialValue: activity.name)
            _lastCompletedAt = State(initialValue: activity.lastCompletedAt)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var navigationTitle: String {
        isEditing ? "Edit Activity" : "New Activity"
    }

    private var saveButtonTitle: String {
        isEditing ? "Done" : "Add"
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Activity Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)

                    DatePicker(
                        "Last Done",
                        selection: $lastCompletedAt,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                if case .edit(let activity) = mode {
                    Section {
                        Button(role: .destructive) {
                            isShowingDeleteConfirmation = true
                        } label: {
                            Text("Delete Activity")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .confirmationDialog(
                        "Delete Activity",
                        isPresented: $isShowingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            store.delete(id: activity.id)
                            dismiss()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete this activity?")
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveButtonTitle) {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .task {
                if case .create = mode {
                    // Small delay ensures sheet presentation animation completes smoothly before keyboard appears
                    try? await Task.sleep(for: .milliseconds(180))
                    isNameFocused = true
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        switch mode {
        case .create:
            store.add(name: trimmedName, lastCompletedAt: lastCompletedAt)
        case .edit(let activity):
            store.update(id: activity.id, name: trimmedName, lastCompletedAt: lastCompletedAt)
        }
        dismiss()
    }
}

struct ActivityEditSheet_Previews: PreviewProvider {
    static var previews: some View {
        ActivityEditSheet(mode: .create)
            .environmentObject(ActivityStore.preview)
    }
}
