import SwiftUI
import SwiftData

struct PreviewView: View {
    @ObservedObject var viewModel: CreateViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showInstallSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    shortcutHeader

                    stepsList

                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Installed!", isPresented: $showInstallSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your shortcut has been sent to the Shortcuts app.")
            }
        }
    }

    private var shortcutHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: "8B5CF6"))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.shortcutName)
                    .font(.title2.bold())
                Text("\(viewModel.previewSteps.count) steps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var stepsList: some View {
        VStack(spacing: 8) {
            ForEach(Array(viewModel.previewSteps.enumerated()), id: \.element.id) { index, step in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "8B5CF6").opacity(0.2))
                            .frame(width: 32, height: 32)
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }

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

                    Spacer()
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.installShortcut()
                viewModel.saveShortcut(context: modelContext)
                showInstallSuccess = true
            } label: {
                HStack {
                    Image(systemName: "arrow.down.app.fill")
                    Text("Install Shortcut")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "10B981"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityLabel("Install shortcut to Shortcuts app")

            HStack(spacing: 12) {
                Button {
                    viewModel.showStepEditor = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Edit Steps")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(hex: "8B5CF6"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "8B5CF6").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Edit shortcut steps")

                Button {
                    viewModel.showModifyWithAI = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Modify with AI")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(hex: "8B5CF6"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "8B5CF6").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Modify shortcut with AI")
            }
        }
    }
}
