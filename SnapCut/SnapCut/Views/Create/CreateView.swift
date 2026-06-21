import SwiftUI
import SwiftData

struct CreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroSection

                    inputSection

                    if let error = viewModel.error {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    if viewModel.isGenerating {
                        generatingAnimation
                    }

                    examplesSection
                }
                .padding()
            }
            .navigationTitle("Create")
            .sheet(isPresented: $viewModel.showPreview) {
                PreviewView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showStepEditor) {
                StepEditorView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showModifyWithAI) {
                ModifyWithAIView(viewModel: viewModel)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "8B5CF6"))

            Text("Describe your shortcut")
                .font(.title2.bold())

            Text("Just tell me what you want to automate")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            TextField("e.g., When I arrive home, turn on lights", text: $viewModel.description, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .lineLimit(3...6)
                .accessibilityLabel("Shortcut description input")
                .accessibilityHint("Describe what you want your shortcut to do")

            Button {
                Task {
                    if viewModel.canGenerate {
                        await viewModel.generate()
                    } else {
                        AppState.shared.showPaywall = true
                    }
                }
            } label: {
                HStack {
                    Image(systemName: viewModel.canGenerate ? "wand.and.stars" : "key.fill")
                    Text(viewModel.generateButtonText)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.canGenerate
                    ? Color(hex: "8B5CF6")
                    : Color.secondary
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.isGenerating || viewModel.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel(viewModel.generateButtonText)
        }
    }

    private var generatingAnimation: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(hex: "8B5CF6"))

            Text("Creating your shortcut...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Try these examples")
                .font(.headline)

            ForEach(viewModel.examplePrompts, id: \.self) { prompt in
                Button {
                    viewModel.description = prompt
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(Color(hex: "F59E0B"))
                        Text(prompt)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Example: \(prompt)")
                .accessibilityHint("Tap to fill the input field")
            }
        }
    }
}

#Preview {
    CreateView()
}
