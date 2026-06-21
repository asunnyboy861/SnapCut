import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isPro: Bool = false
    @Published var hasAPIKey: Bool = false
    @Published var apiKey: String = ""
    @Published var baseURL: String = "https://api.openai.com/v1"
    @Published var model: String = "gpt-4o-mini"
    @Published var isValidating: Bool = false
    @Published var validationMessage: String?
    @Published var showPaywall: Bool = false

    private let aiEngine = AIEngine.shared
    private let purchaseManager = PurchaseManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        purchaseManager.$isPro
            .receive(on: RunLoop.main)
            .assign(to: &$isPro)

        loadAPIKey()
    }

    func loadAPIKey() {
        apiKey = aiEngine.apiKey ?? ""
        baseURL = aiEngine.baseURL ?? "https://api.openai.com/v1"
        model = aiEngine.model ?? "gpt-4o-mini"
        hasAPIKey = aiEngine.hasAPIKey
    }

    func saveAPIKey() {
        if apiKey.isEmpty {
            aiEngine.clearAPIKey()
            hasAPIKey = false
        } else {
            aiEngine.saveAPIKey(apiKey)
            aiEngine.saveBaseURL(baseURL)
            aiEngine.saveModel(model)
            hasAPIKey = true
        }
    }

    func validateAPIKey() async {
        guard !apiKey.isEmpty else {
            validationMessage = "Please enter an API key first."
            return
        }

        isValidating = true
        validationMessage = nil

        saveAPIKey()

        do {
            let testYAML = try await aiEngine.generateShortcutYAML(description: "Test: say hello")
            if !testYAML.isEmpty {
                validationMessage = "API key is valid!"
            } else {
                validationMessage = "API key validation failed."
            }
        } catch {
            validationMessage = "Validation failed: \(error.localizedDescription)"
        }

        isValidating = false
    }

    func restorePurchases() async {
        await purchaseManager.restorePurchases()
    }
}
