import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                proSection

                apiSection

                supportSection

                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var proSection: some View {
        Section {
            HStack {
                Image(systemName: purchaseManager.isPro ? "checkmark.seal.fill" : "lock.fill")
                    .foregroundStyle(purchaseManager.isPro ? Color(hex: "10B981") : Color(hex: "F59E0B"))
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(purchaseManager.isPro ? "Pro Active" : "Free Plan")
                        .font(.headline)
                    Text(purchaseManager.isPro ? "All features unlocked" : "Upgrade for full access")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !purchaseManager.isPro {
                    Button("Upgrade") { showPaywall = true }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "8B5CF6"))
                }
            }

            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("Membership")
        }
    }

    private var apiSection: some View {
        Section {
            TextField("API Key", text: $viewModel.apiKey)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            TextField("Base URL", text: $viewModel.baseURL)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            TextField("Model", text: $viewModel.model)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            HStack {
                Button {
                    Task { await viewModel.validateAPIKey() }
                } label: {
                    Label("Validate", systemImage: "checkmark.circle")
                }
                .disabled(viewModel.isValidating)

                Button("Save") {
                    viewModel.saveAPIKey()
                }
            }

            if let message = viewModel.validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(message.contains("valid") ? Color(hex: "10B981") : .red)
            }

            Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                Label("Get OpenAI API Key", systemImage: "key.fill")
            }

        } header: {
            Text("AI Configuration")
        } footer: {
            Text("Bring your own API key for AI-powered shortcut generation. Your key is stored securely on-device only.")
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Link(destination: URL(string: "https://zzoutuo.github.io/SnapCut/support")!) {
                Label("Help & Support", systemImage: "questionmark.circle")
            }
            Link(destination: URL(string: "mailto:support@zzoutuo.com")!) {
                Label("Contact Us", systemImage: "envelope")
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/SnapCut/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/SnapCut/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            HStack {
                Text("Build")
                Spacer()
                Text("1").foregroundStyle(.secondary)
            }
            Link(destination: URL(string: "https://zzoutuo.github.io/SnapCut")!) {
                Label("Website", systemImage: "globe")
            }
        }
    }
}

#Preview {
    SettingsView()
}
