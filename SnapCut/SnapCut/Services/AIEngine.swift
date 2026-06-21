import Foundation
import Combine

@MainActor
class AIEngine: ObservableObject {
    static let shared = AIEngine()

    @Published var isGenerating: Bool = false

    private let keychainService = "com.zzoutuo.SnapCut"
    private let keychainAccount = "api_key"
    private let keychainBaseURLAccount = "api_base_url"
    private let keychainModelAccount = "api_model"

    var apiKey: String? {
        KeychainHelper.readString(service: keychainService, account: keychainAccount)
    }

    var baseURL: String? {
        KeychainHelper.readString(service: keychainService, account: keychainBaseURLAccount)
    }

    var model: String? {
        KeychainHelper.readString(service: keychainService, account: keychainModelAccount)
    }

    var hasAPIKey: Bool {
        !(apiKey?.isEmpty ?? true)
    }

    func saveAPIKey(_ key: String) {
        KeychainHelper.save(key, service: keychainService, account: keychainAccount)
    }

    func saveBaseURL(_ url: String) {
        KeychainHelper.save(url, service: keychainService, account: keychainBaseURLAccount)
    }

    func saveModel(_ model: String) {
        KeychainHelper.save(model, service: keychainService, account: keychainModelAccount)
    }

    func clearAPIKey() {
        KeychainHelper.delete(service: keychainService, account: keychainAccount)
        KeychainHelper.delete(service: keychainService, account: keychainBaseURLAccount)
        KeychainHelper.delete(service: keychainService, account: keychainModelAccount)
    }

    private let systemPrompt = """
    You are a Shortcut YAML generator. Convert the user's natural language description into a Shortcut YAML format.

    Format:
    name: [Shortcut Name]
    icon: [SF Symbol name]
    color: [Hex color without #]
    steps:
      - action: [Action Name]
        icon: [SF Symbol name]
        parameters:
          [key]: "[value]"
        summary: "[Human readable description of this step]"

    Common actions: Set Variable, Get Variable, If, Text, Date, Calculate, Show Result, Send Message, Make HTTP Request, Open App, Set Low Power Mode, Set Appearance, Take Screenshot, Get Current Location, Get Weather, Set Volume, Play Sound, Start Timer, Add New Event, Add New Reminder, Copy to Clipboard, Get Clipboard, Open URLs, Search Web, Speak Text, Get Battery Level, Set Brightness, Set Flashlight, Vibrate Device, Share Sheet, Get Contents of URL, Save File, Get File, Make Archive, Get Latest Photos, Take Photo, Resize Image, Convert Image, Get Details of Images, Get Exif Metadata, Get Heart Rate, Get Steps, Get Workouts, Log Health Sample, Get Weather Forecast, Get Air Quality, Get UV Index, Get Sunrise/Sunset, Get Elevation, Get Distance, Get Travel Time, Get Directions, Show in Maps, Search Local Businesses, Call, FaceTime, Send Email, Add to Reading List, Scan QR/Barcode, Show Web Page, Get Device Details, Get Current IP Address, Set Wi-Fi, Set Bluetooth, Set Cellular Data, Set Do Not Disturb, Get Network Details, Detect Language, Translate Text, Base64 Encode, Base64 Decode, Run JavaScript on Web Page, Get Type, Append to File, Delete Files, Make Video from Images, Extract Archive, Set AirDrop Mode, Set Hotspot, Set Stage Manager, Get Screen Time, Set Screen Time, Get Carplay Details, Get EV Charging Stations, Get Parking Location, Set Parking Location, Get Time to Destination, Get ETA, Get Traffic, Get Road Conditions, Get Speed, Get Heading, Get Altitude, Get Course, Get Distance Traveled, Get Moon Phase, Get Climate, Get Season, Get Average Weather, Get Latest Bursts, Convert HEIF to JPEG, Set Always On Display, Get Exif Metadata

    Rules:
    1. Generate ONLY valid YAML, no markdown code blocks
    2. Use descriptive action names from the list above
    3. Each step must have a human-readable summary
    4. Use appropriate SF Symbol names for icons
    5. Keep the shortcut focused and practical
    6. Use {{parameter_name}} for user-configurable values
    """

    func generateShortcutYAML(description: String) async throws -> String {
        guard hasAPIKey else {
            return generateLocalYAML(description: description)
        }

        let url = URL(string: baseURL ?? "https://api.openai.com/v1")!
        let chatURL = url.appendingPathComponent("/chat/completions")
        let request = buildRequest(url: chatURL, messages: [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": description]
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return generateLocalYAML(description: description)
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return generateLocalYAML(description: description)
    }

    func refineShortcutYAML(currentYAML: String, modification: String) async throws -> String {
        guard hasAPIKey else {
            return generateLocalYAML(description: modification, baseYAML: currentYAML)
        }

        let url = URL(string: baseURL ?? "https://api.openai.com/v1")!
        let chatURL = url.appendingPathComponent("/chat/completions")
        let userContent = "Current shortcut YAML:\n\(currentYAML)\n\nModification request: \(modification)\n\nReturn the updated complete YAML."
        let request = buildRequest(url: chatURL, messages: [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userContent]
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return generateLocalYAML(description: modification, baseYAML: currentYAML)
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return generateLocalYAML(description: modification, baseYAML: currentYAML)
    }

    private func buildRequest(url: URL, messages: [[String: String]]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model ?? "gpt-4o-mini",
            "messages": messages,
            "temperature": 0.7
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func generateLocalYAML(description: String, baseYAML: String? = nil) -> String {
        let name = extractName(from: description) ?? "Custom Shortcut"
        let steps = generateSteps(from: description)

        var yaml = "name: \(name)\n"
        yaml += "icon: wand.and.stars\n"
        yaml += "color: \"8B5CF6\"\n"
        yaml += "steps:\n"
        for step in steps {
            yaml += "  - action: \(step.actionName)\n"
            yaml += "    icon: \(step.icon)\n"
            yaml += "    summary: \"\(step.summary)\"\n"
        }
        return yaml
    }

    private func extractName(from description: String) -> String? {
        let lower = description.lowercased()

        if lower.contains("morning") || lower.contains("wake") {
            return "Morning Routine"
        }
        if lower.contains("home") || lower.contains("arrive") {
            return "Arrive Home"
        }
        if lower.contains("work") || lower.contains("office") {
            return "Work Mode"
        }
        if lower.contains("workout") || lower.contains("exercise") || lower.contains("run") {
            return "Workout Starter"
        }
        if lower.contains("sleep") || lower.contains("bed") || lower.contains("night") {
            return "Bedtime Mode"
        }
        if lower.contains("text") || lower.contains("message") {
            return "Quick Message"
        }
        if lower.contains("timer") || lower.contains("reminder") {
            return "Quick Timer"
        }
        if lower.contains("photo") || lower.contains("camera") {
            return "Photo Helper"
        }
        if lower.contains("weather") {
            return "Weather Check"
        }
        if lower.contains("battery") || lower.contains("power") {
            return "Power Saver"
        }

        let words = description.split(separator: " ").prefix(3)
        return words.isEmpty ? "Custom Shortcut" : words.joined(separator: " ").capitalized
    }

    private func generateSteps(from description: String) -> [ShortcutStep] {
        let lower = description.lowercased()
        var steps: [ShortcutStep] = []

        if lower.contains("home") || lower.contains("arrive") {
            steps.append(ShortcutStep(actionName: "Get Current Location", icon: "location.fill", summary: "Check current location"))
            steps.append(ShortcutStep(actionName: "If", icon: "arrow.triangle.branch", summary: "If at home location"))
            steps.append(ShortcutStep(actionName: "Set Appearance", icon: "sun.max.fill", summary: "Set appearance to dark mode"))
        }

        if lower.contains("light") {
            steps.append(ShortcutStep(actionName: "Set Variable", icon: "variable.fill", summary: "Set lights variable"))
            steps.append(ShortcutStep(actionName: "Show Result", icon: "lightbulb.fill", summary: "Turn on lights"))
        }

        if lower.contains("music") || lower.contains("play") || lower.contains("jazz") {
            steps.append(ShortcutStep(actionName: "Open App", icon: "music.note", summary: "Open Music app"))
            steps.append(ShortcutStep(actionName: "Play Sound", icon: "play.circle.fill", summary: "Play music"))
        }

        if lower.contains("morning") || lower.contains("wake") {
            steps.append(ShortcutStep(actionName: "Get Weather", icon: "cloud.sun.fill", summary: "Get today's weather"))
            steps.append(ShortcutStep(actionName: "Speak Text", icon: "speaker.wave.2.fill", summary: "Speak weather forecast"))
            steps.append(ShortcutStep(actionName: "Show Result", icon: "sun.max.fill", summary: "Display morning summary"))
        }

        if lower.contains("text") || lower.contains("message") {
            steps.append(ShortcutStep(actionName: "Send Message", icon: "message.fill", summary: "Send message to contact"))
        }

        if lower.contains("timer") {
            steps.append(ShortcutStep(actionName: "Start Timer", icon: "timer", summary: "Start a timer"))
        }

        if lower.contains("reminder") {
            steps.append(ShortcutStep(actionName: "Add New Reminder", icon: "checklist", summary: "Create a new reminder"))
        }

        if lower.contains("event") || lower.contains("calendar") {
            steps.append(ShortcutStep(actionName: "Add New Event", icon: "calendar", summary: "Add event to calendar"))
        }

        if lower.contains("weather") {
            steps.append(ShortcutStep(actionName: "Get Weather", icon: "cloud.sun.fill", summary: "Get current weather"))
            steps.append(ShortcutStep(actionName: "Show Result", icon: "sun.max.fill", summary: "Display weather information"))
        }

        if lower.contains("battery") || lower.contains("power") {
            steps.append(ShortcutStep(actionName: "Get Battery Level", icon: "battery.25", summary: "Check battery level"))
            steps.append(ShortcutStep(actionName: "Set Low Power Mode", icon: "bolt.fill", summary: "Enable low power mode"))
        }

        if lower.contains("screenshot") {
            steps.append(ShortcutStep(actionName: "Take Screenshot", icon: "camera.viewfinder", summary: "Capture screenshot"))
        }

        if lower.contains("clipboard") || lower.contains("copy") {
            steps.append(ShortcutStep(actionName: "Copy to Clipboard", icon: "doc.on.doc.fill", summary: "Copy to clipboard"))
        }

        if lower.contains("email") {
            steps.append(ShortcutStep(actionName: "Send Email", icon: "envelope.fill", summary: "Send email"))
        }

        if lower.contains("volume") {
            steps.append(ShortcutStep(actionName: "Set Volume", icon: "speaker.wave.3.fill", summary: "Adjust volume"))
        }

        if lower.contains("brightness") {
            steps.append(ShortcutStep(actionName: "Set Brightness", icon: "sun.max.fill", summary: "Adjust screen brightness"))
        }

        if lower.contains("wifi") {
            steps.append(ShortcutStep(actionName: "Set Wi-Fi", icon: "wifi", summary: "Toggle Wi-Fi"))
        }

        if lower.contains("bluetooth") {
            steps.append(ShortcutStep(actionName: "Set Bluetooth", icon: "dot.radiowaves.left.and.right", summary: "Toggle Bluetooth"))
        }

        if lower.contains("flashlight") {
            steps.append(ShortcutStep(actionName: "Set Flashlight", icon: "flashlight.off.fill", summary: "Toggle flashlight"))
        }

        if steps.isEmpty {
            steps.append(ShortcutStep(actionName: "Show Result", icon: "info.circle.fill", summary: "Display result"))
            steps.append(ShortcutStep(actionName: "Copy to Clipboard", icon: "doc.on.doc.fill", summary: "Copy to clipboard"))
        }

        return steps
    }
}
