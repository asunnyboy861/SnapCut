import Foundation
import SwiftUI
import Combine
import SwiftData

@MainActor
class CreateViewModel: ObservableObject {
    @Published var description: String = ""
    @Published var isGenerating: Bool = false
    @Published var generatedYAML: String = ""
    @Published var previewSteps: [ShortcutStep] = []
    @Published var shortcutName: String = ""
    @Published var error: String?
    @Published var showPreview: Bool = false
    @Published var showStepEditor: Bool = false
    @Published var showModifyWithAI: Bool = false

    private let aiEngine = AIEngine.shared
    private let compiler = ShortcutCompiler.shared
    private let purchaseManager = PurchaseManager.shared

    var canGenerate: Bool {
        purchaseManager.isPro || aiEngine.hasAPIKey
    }

    var generateButtonText: String {
        if canGenerate {
            return "SnapCut It!"
        }
        return "Set Up API Key"
    }

    func generate() async {
        guard canGenerate else { return }
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Please describe what you want your shortcut to do."
            return
        }

        isGenerating = true
        error = nil

        do {
            let yaml = try await aiEngine.generateShortcutYAML(description: description)
            generatedYAML = yaml
            previewSteps = compiler.parseYAML(yaml)
            shortcutName = extractName(from: yaml) ?? "Custom Shortcut"
            isGenerating = false
            showPreview = true
        } catch {
            self.error = "Failed to generate shortcut. Please try again."
            isGenerating = false
        }
    }

    func modifyWithAI(_ modification: String) async {
        guard !modification.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isGenerating = true
        error = nil

        do {
            let updatedYAML = try await aiEngine.refineShortcutYAML(currentYAML: generatedYAML, modification: modification)
            generatedYAML = updatedYAML
            previewSteps = compiler.parseYAML(updatedYAML)
            isGenerating = false
        } catch {
            self.error = "Failed to modify shortcut. Please try again."
            isGenerating = false
        }
    }

    func updateSteps(_ steps: [ShortcutStep]) {
        previewSteps = steps
        generatedYAML = compiler.generateYAML(name: shortcutName, steps: steps)
    }

    func saveShortcut(context: ModelContext) {
        let shortcut = UserShortcut(
            name: shortcutName,
            yaml: generatedYAML,
            icon: "wand.and.stars",
            color: "8B5CF6",
            source: "created"
        )
        context.insert(shortcut)
        try? context.save()
    }

    func installShortcut() {
        guard let url = compiler.installShortcutURL(name: shortcutName) else { return }
        UIApplication.shared.open(url)
    }

    private func extractName(from yaml: String) -> String? {
        for line in yaml.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("name:") {
                return trimmed.replacingOccurrences(of: "name:", with: "").trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    let examplePrompts: [String] = [
        "When I arrive home, turn on lights and play jazz",
        "Every morning at 7am, tell me the weather and my first event",
        "Take a screenshot and save it to Photos",
        "Send a text to my partner when I leave work",
        "Start a 25-minute focus timer with Do Not Disturb"
    ]
}
