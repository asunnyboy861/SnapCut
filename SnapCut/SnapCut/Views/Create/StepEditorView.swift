import SwiftUI

struct StepEditorView: View {
    @ObservedObject var viewModel: CreateViewModel
    @State private var steps: [ShortcutStep] = []
    @State private var showActionPicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(steps) { step in
                    HStack(spacing: 12) {
                        Image(systemName: step.icon)
                            .font(.title3)
                            .foregroundStyle(Color(hex: "8B5CF6"))
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.actionName)
                                .font(.subheadline.bold())
                            Text(step.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    steps.remove(atOffsets: indexSet)
                }
                .onMove { source, destination in
                    steps.move(fromOffsets: source, toOffset: destination)
                }
            }
            .navigationTitle("Edit Steps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.updateSteps(steps)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showActionPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }
                }
            }
            .sheet(isPresented: $showActionPicker) {
                ActionPickerView { action in
                    steps.append(ShortcutStep(
                        actionName: action.name,
                        icon: action.icon,
                        summary: action.description
                    ))
                }
            }
            .onAppear {
                steps = viewModel.previewSteps
            }
        }
    }
}

struct ActionPickerView: View {
    @StateObject private var discoveryService = ActionDiscoveryService.shared
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @Environment(\.dismiss) private var dismiss
    let onSelect: (ShortcutAction) -> Void

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    ForEach(discoveryService.categories) { category in
                        Section(category.name) {
                            ForEach(category.actions) { action in
                                Button {
                                    onSelect(action)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: action.icon)
                                            .font(.title3)
                                            .foregroundStyle(Color(hex: "8B5CF6"))
                                            .frame(width: 32)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(action.name)
                                                .font(.subheadline.bold())
                                                .foregroundStyle(.primary)
                                            Text(action.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else {
                    ForEach(filteredActions, id: \.id) { action in
                        Button {
                            onSelect(action)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: action.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: "8B5CF6"))
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(action.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)
                                    Text(action.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search actions")
            .navigationTitle("Add Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var filteredActions: [ShortcutAction] {
        let lower = searchText.lowercased()
        return discoveryService.allActions.filter { action in
            action.name.lowercased().contains(lower) ||
            action.description.lowercased().contains(lower) ||
            action.category.lowercased().contains(lower)
        }
    }
}
