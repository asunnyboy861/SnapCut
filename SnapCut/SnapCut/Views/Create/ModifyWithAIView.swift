import SwiftUI

struct ModifyWithAIView: View {
    @ObservedObject var viewModel: CreateViewModel
    @State private var modification: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Modify with AI")
                        .font(.title2.bold())

                    Text("Describe what you want to change about your shortcut")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                TextField("e.g., Add a notification at the end", text: $modification, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .lineLimit(3...6)
                    .padding(.horizontal)
                    .accessibilityLabel("Modification description")

                if viewModel.isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color(hex: "8B5CF6"))
                        Text("Modifying...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.modifyWithAI(modification)
                        if viewModel.error == nil {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Apply Modification")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "8B5CF6"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(modification.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGenerating)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("AI Modify")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
