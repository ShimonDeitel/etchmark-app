import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var selectedItem: Run?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Runs")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .tint(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd() {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .tint(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil) { newItem in
                    store.add(newItem)
                }
            }
            .sheet(item: $selectedItem) { item in
                EditItemView(item: item) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    selectedItem = item
                } label: {
                    ItemRow(item: item)
                }
                .accessibilityIdentifier("row_\(item.title.isEmpty ? item.id.uuidString : item.title)")
                .listRowBackground(Theme.card)
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textMuted)
            Text("No runs yet")
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.text)
            Text("Tap + to log your first one.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textMuted)
        }
    }
}

private struct ItemRow: View {
    let item: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.text)
            if !item.plateType.isEmpty {
            Text(item.plateType)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textMuted)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LabeledRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundStyle(Theme.textMuted)
            Text(value)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.text)
        }
        .padding(.vertical, 4)
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Run
    private let isNew: Bool
    private let onSave: (Run) -> Void

    init(item: Run?, onSave: @escaping (Run) -> Void) {
        _draft = State(initialValue: item ?? Run())
        self.isNew = item == nil
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                TextField("Print Title", text: $draft.title)
                    .accessibilityIdentifier("field_title")
                TextField("Plate Type", text: $draft.plateType, axis: .vertical)
                    .accessibilityIdentifier("field_plateType")
                TextField("Ink & Paper", text: $draft.inkPaper, axis: .vertical)
                    .accessibilityIdentifier("field_inkPaper")
                TextField("Edition Size", text: $draft.editionSize, axis: .vertical)
                    .accessibilityIdentifier("field_editionSize")
                TextField("Notes", text: $draft.notes, axis: .vertical)
                    .accessibilityIdentifier("field_notes")
                }
            }
            .navigationTitle(isNew ? "New Run" : "Edit Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
