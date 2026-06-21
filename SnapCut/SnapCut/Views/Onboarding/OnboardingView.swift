import SwiftUI

struct OnboardingView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedMode: OnboardingMode?

    enum OnboardingMode: String, CaseIterable {
        case template = "Try a Template"
        case ai = "Create with AI"
        case scratch = "Start from Scratch"

        var icon: String {
            switch self {
            case .template: return "square.stack.3d.up.fill"
            case .ai: return "wand.and.stars"
            case .scratch: return "square.and.pencil"
            }
        }

        var description: String {
            switch self {
            case .template: return "Browse our gallery of pre-made shortcuts"
            case .ai: return "Describe what you want in natural language"
            case .scratch: return "Build a shortcut step by step"
            }
        }

        var color: Color {
            switch self {
            case .template: return Color(hex: "3B82F6")
            case .ai: return Color(hex: "8B5CF6")
            case .scratch: return Color(hex: "10B981")
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 72))
                    .foregroundStyle(Color(hex: "8B5CF6"))
                    .padding(.top, 60)

                Text("SnapCut")
                    .font(.largeTitle.bold())

                Text("Describe it. SnapCut it. Done.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(OnboardingMode.allCases, id: \.self) { mode in
                    Button {
                        selectedMode = mode
                        completeOnboarding(mode: mode)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: mode.icon)
                                .font(.title2)
                                .foregroundStyle(mode.color)
                                .frame(width: 48, height: 48)
                                .background(mode.color.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(mode.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mode.rawValue)
                    .accessibilityHint(mode.description)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            Spacer()

            Button("Skip") {
                completeOnboarding(mode: .ai)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    private func completeOnboarding(mode: OnboardingMode) {
        withAnimation {
            appState.completeOnboarding()
            switch mode {
            case .template:
                appState.selectTab(1)
            case .ai:
                appState.selectTab(0)
            case .scratch:
                appState.selectTab(0)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
