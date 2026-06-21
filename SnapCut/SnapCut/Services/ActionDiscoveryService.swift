import Foundation
import Combine

@MainActor
class ActionDiscoveryService: ObservableObject {
    static let shared = ActionDiscoveryService()

    @Published var categories: [ActionCategory] = []
    @Published var allActions: [ShortcutAction] = []
    @Published var searchResults: [ShortcutAction] = []

    init() {
        loadCatalog()
    }

    private func loadCatalog() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json", subdirectory: "Actions"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ActionCategory].self, from: data) else {
            categories = buildBuiltinCatalog()
            allActions = categories.flatMap { $0.actions }
            return
        }

        categories = decoded
        allActions = decoded.flatMap { $0.actions }
    }

    func search(query: String) {
        if query.isEmpty {
            searchResults = allActions
        } else {
            let lower = query.lowercased()
            searchResults = allActions.filter { action in
                action.name.lowercased().contains(lower) ||
                action.description.lowercased().contains(lower) ||
                action.category.lowercased().contains(lower)
            }
        }
    }

    func actions(in category: String) -> [ShortcutAction] {
        allActions.filter { $0.category == category }
    }

    private func buildBuiltinCatalog() -> [ActionCategory] {
        return [
            ActionCategory(id: "scripts", name: "Scripts", icon: "scroll.fill", actions: [
                ShortcutAction(id: "run-shortcut", name: "Run Shortcut", category: "Scripts", icon: "play.fill", description: "Run another shortcut", parameters: []),
                ShortcutAction(id: "exit-shortcut", name: "Exit Shortcut", category: "Scripts", icon: "xmark.circle.fill", description: "Stop the current shortcut", parameters: []),
                ShortcutAction(id: "nothing", name: "Nothing", category: "Scripts", icon: "circle", description: "Do nothing", parameters: []),
                ShortcutAction(id: "wait", name: "Wait", category: "Scripts", icon: "clock.fill", description: "Wait for a specified duration", parameters: [
                    ActionParameter(name: "seconds", type: "number", defaultValue: "1", required: true)
                ])
            ]),
            ActionCategory(id: "media", name: "Media", icon: "photo.fill", actions: [
                ShortcutAction(id: "take-photo", name: "Take Photo", category: "Media", icon: "camera.fill", description: "Take a photo with the camera", parameters: []),
                ShortcutAction(id: "get-latest-photos", name: "Get Latest Photos", category: "Media", icon: "photo.on.rectangle.angled", description: "Get recent photos from library", parameters: [
                    ActionParameter(name: "count", type: "number", defaultValue: "1", required: true)
                ]),
                ShortcutAction(id: "select-photos", name: "Select Photos", category: "Media", icon: "photo.badge.checkmark", description: "Select photos from library", parameters: []),
                ShortcutAction(id: "resize-image", name: "Resize Image", category: "Media", icon: "arrow.up.left.and.arrow.down.right", description: "Resize an image", parameters: []),
                ShortcutAction(id: "convert-image", name: "Convert Image", category: "Media", icon: "arrow.triangle.2.circlepath", description: "Convert image format", parameters: []),
                ShortcutAction(id: "make-video", name: "Make Video from Images", category: "Media", icon: "video.fill", description: "Create video from images", parameters: []),
                ShortcutAction(id: "play-sound", name: "Play Sound", category: "Media", icon: "speaker.wave.2.fill", description: "Play a sound", parameters: []),
                ShortcutAction(id: "set-volume", name: "Set Volume", category: "Media", icon: "speaker.wave.3.fill", description: "Set device volume", parameters: [
                    ActionParameter(name: "volume", type: "number", defaultValue: "50", required: true)
                ])
            ]),
            ActionCategory(id: "location", name: "Location", icon: "location.fill", actions: [
                ShortcutAction(id: "get-location", name: "Get Current Location", category: "Location", icon: "location.fill", description: "Get current GPS location", parameters: []),
                ShortcutAction(id: "get-directions", name: "Get Directions", category: "Location", icon: "arrow.triangle.turn.up.right.diamond.fill", description: "Get directions to a location", parameters: []),
                ShortcutAction(id: "show-in-maps", name: "Show in Maps", category: "Location", icon: "map.fill", description: "Show location in Maps app", parameters: []),
                ShortcutAction(id: "get-distance", name: "Get Distance", category: "Location", icon: "ruler", description: "Get distance between locations", parameters: []),
                ShortcutAction(id: "get-travel-time", name: "Get Travel Time", category: "Location", icon: "clock.arrow.circlepath", description: "Get travel time", parameters: []),
                ShortcutAction(id: "search-local", name: "Search Local Businesses", category: "Location", icon: "magnifyingglass", description: "Search for nearby businesses", parameters: [])
            ]),
            ActionCategory(id: "text", name: "Text", icon: "textformat", actions: [
                ShortcutAction(id: "text", name: "Text", category: "Text", icon: "text.alignleft", description: "Create text", parameters: [
                    ActionParameter(name: "text", type: "text", defaultValue: "", required: true)
                ]),
                ShortcutAction(id: "speak-text", name: "Speak Text", category: "Text", icon: "speaker.wave.2.fill", description: "Speak text aloud", parameters: []),
                ShortcutAction(id: "translate-text", name: "Translate Text", category: "Text", icon: "character.book.closed.fill", description: "Translate text to another language", parameters: []),
                ShortcutAction(id: "detect-language", name: "Detect Language", category: "Text", icon: "globe", description: "Detect the language of text", parameters: []),
                ShortcutAction(id: "copy-clipboard", name: "Copy to Clipboard", category: "Text", icon: "doc.on.doc.fill", description: "Copy text to clipboard", parameters: []),
                ShortcutAction(id: "get-clipboard", name: "Get Clipboard", category: "Text", icon: "doc.on.clipboard", description: "Get clipboard contents", parameters: []),
                ShortcutAction(id: "base64-encode", name: "Base64 Encode", category: "Text", icon: "number", description: "Encode text as Base64", parameters: []),
                ShortcutAction(id: "base64-decode", name: "Base64 Decode", category: "Text", icon: "number.circle", description: "Decode Base64 text", parameters: [])
            ]),
            ActionCategory(id: "dates", name: "Dates", icon: "calendar", actions: [
                ShortcutAction(id: "date", name: "Date", category: "Dates", icon: "calendar", description: "Get current date", parameters: []),
                ShortcutAction(id: "add-event", name: "Add New Event", category: "Dates", icon: "calendar.badge.plus", description: "Add event to calendar", parameters: []),
                ShortcutAction(id: "add-reminder", name: "Add New Reminder", category: "Dates", icon: "checklist", description: "Add reminder", parameters: []),
                ShortcutAction(id: "start-timer", name: "Start Timer", category: "Dates", icon: "timer", description: "Start a countdown timer", parameters: [
                    ActionParameter(name: "seconds", type: "number", defaultValue: "60", required: true)
                ])
            ]),
            ActionCategory(id: "device", name: "Device", icon: "iphone", actions: [
                ShortcutAction(id: "set-brightness", name: "Set Brightness", category: "Device", icon: "sun.max.fill", description: "Set screen brightness", parameters: [
                    ActionParameter(name: "brightness", type: "number", defaultValue: "50", required: true)
                ]),
                ShortcutAction(id: "set-wifi", name: "Set Wi-Fi", category: "Device", icon: "wifi", description: "Toggle Wi-Fi", parameters: []),
                ShortcutAction(id: "set-bluetooth", name: "Set Bluetooth", category: "Device", icon: "dot.radiowaves.left.and.right", description: "Toggle Bluetooth", parameters: []),
                ShortcutAction(id: "set-cellular", name: "Set Cellular Data", category: "Device", icon: "antenna.radiowaves.left.and.right", description: "Toggle cellular data", parameters: []),
                ShortcutAction(id: "set-low-power", name: "Set Low Power Mode", category: "Device", icon: "bolt.fill", description: "Toggle low power mode", parameters: []),
                ShortcutAction(id: "set-appearance", name: "Set Appearance", category: "Device", icon: "circle.lefthalf.filled", description: "Set dark/light mode", parameters: []),
                ShortcutAction(id: "set-flashlight", name: "Set Flashlight", category: "Device", icon: "flashlight.off.fill", description: "Toggle flashlight", parameters: []),
                ShortcutAction(id: "set-airdrop", name: "Set AirDrop Mode", category: "Device", icon: "share", description: "Toggle AirDrop", parameters: []),
                ShortcutAction(id: "set-dnd", name: "Set Do Not Disturb", category: "Device", icon: "moon.fill", description: "Toggle Do Not Disturb", parameters: []),
                ShortcutAction(id: "vibrate", name: "Vibrate Device", category: "Device", icon: "iphone.radiowaves.left.and.right", description: "Vibrate the device", parameters: []),
                ShortcutAction(id: "take-screenshot", name: "Take Screenshot", category: "Device", icon: "camera.viewfinder", description: "Capture screenshot", parameters: []),
                ShortcutAction(id: "get-battery", name: "Get Battery Level", category: "Device", icon: "battery.25", description: "Get battery percentage", parameters: []),
                ShortcutAction(id: "get-device-details", name: "Get Device Details", category: "Device", icon: "info.circle", description: "Get device information", parameters: [])
            ]),
            ActionCategory(id: "web", name: "Web", icon: "globe", actions: [
                ShortcutAction(id: "open-urls", name: "Open URLs", category: "Web", icon: "safari.fill", description: "Open URLs in browser", parameters: []),
                ShortcutAction(id: "show-web-page", name: "Show Web Page", category: "Web", icon: "safari", description: "Show a web page", parameters: []),
                ShortcutAction(id: "search-web", name: "Search Web", category: "Web", icon: "magnifyingglass", description: "Search the web", parameters: []),
                ShortcutAction(id: "get-contents-url", name: "Get Contents of URL", category: "Web", icon: "network", description: "Fetch URL contents", parameters: []),
                ShortcutAction(id: "make-http-request", name: "Make HTTP Request", category: "Web", icon: "network", description: "Send HTTP request", parameters: []),
                ShortcutAction(id: "run-javascript", name: "Run JavaScript on Web Page", category: "Web", icon: "chevron.left.forwardslash.chevron.right", description: "Run JS on Safari page", parameters: []),
                ShortcutAction(id: "scan-qr", name: "Scan QR/Barcode", category: "Web", icon: "qrcode.viewfinder", description: "Scan QR code", parameters: [])
            ]),
            ActionCategory(id: "communication", name: "Communication", icon: "message.fill", actions: [
                ShortcutAction(id: "send-message", name: "Send Message", category: "Communication", icon: "message.fill", description: "Send iMessage/SMS", parameters: []),
                ShortcutAction(id: "send-email", name: "Send Email", category: "Communication", icon: "envelope.fill", description: "Send email", parameters: []),
                ShortcutAction(id: "call", name: "Call", category: "Communication", icon: "phone.fill", description: "Make a phone call", parameters: []),
                ShortcutAction(id: "facetime", name: "FaceTime", category: "Communication", icon: "video.fill", description: "Start FaceTime call", parameters: []),
                ShortcutAction(id: "share-sheet", name: "Share Sheet", category: "Communication", icon: "square.and.arrow.up", description: "Show share sheet", parameters: [])
            ]),
            ActionCategory(id: "health", name: "Health", icon: "heart.fill", actions: [
                ShortcutAction(id: "get-heart-rate", name: "Get Heart Rate", category: "Health", icon: "heart.fill", description: "Get latest heart rate", parameters: []),
                ShortcutAction(id: "get-steps", name: "Get Steps", category: "Health", icon: "figure.walk", description: "Get step count", parameters: []),
                ShortcutAction(id: "get-workouts", name: "Get Workouts", category: "Health", icon: "figure.run", description: "Get workout data", parameters: []),
                ShortcutAction(id: "log-health", name: "Log Health Sample", category: "Health", icon: "heart.text.square.fill", description: "Log health data", parameters: []),
                ShortcutAction(id: "get-sleep", name: "Get Sleep Analysis", category: "Health", icon: "bed.double.fill", description: "Get sleep data", parameters: [])
            ]),
            ActionCategory(id: "weather", name: "Weather", icon: "cloud.sun.fill", actions: [
                ShortcutAction(id: "get-weather", name: "Get Weather", category: "Weather", icon: "cloud.sun.fill", description: "Get current weather", parameters: []),
                ShortcutAction(id: "get-weather-forecast", name: "Get Weather Forecast", category: "Weather", icon: "cloud.sun.rain.fill", description: "Get weather forecast", parameters: []),
                ShortcutAction(id: "get-air-quality", name: "Get Air Quality", category: "Weather", icon: "aqi.medium", description: "Get air quality index", parameters: []),
                ShortcutAction(id: "get-uv-index", name: "Get UV Index", category: "Weather", icon: "sun.max.fill", description: "Get UV index", parameters: []),
                ShortcutAction(id: "get-sunrise", name: "Get Sunrise/Sunset", category: "Weather", icon: "sunrise.fill", description: "Get sunrise/sunset times", parameters: [])
            ]),
            ActionCategory(id: "files", name: "Files", icon: "folder.fill", actions: [
                ShortcutAction(id: "save-file", name: "Save File", category: "Files", icon: "folder.badge.plus", description: "Save a file", parameters: []),
                ShortcutAction(id: "get-file", name: "Get File", category: "Files", icon: "folder.fill", description: "Get a file", parameters: []),
                ShortcutAction(id: "append-file", name: "Append to File", category: "Files", icon: "text.badge.plus", description: "Append to a file", parameters: []),
                ShortcutAction(id: "delete-files", name: "Delete Files", category: "Files", icon: "trash.fill", description: "Delete files", parameters: []),
                ShortcutAction(id: "make-archive", name: "Make Archive", category: "Files", icon: "archivebox.fill", description: "Create zip archive", parameters: []),
                ShortcutAction(id: "extract-archive", name: "Extract Archive", category: "Files", icon: "archivebox.fill", description: "Extract zip archive", parameters: [])
            ]),
            ActionCategory(id: "math", name: "Math", icon: "function", actions: [
                ShortcutAction(id: "calculate", name: "Calculate", category: "Math", icon: "function", description: "Perform calculation", parameters: []),
                ShortcutAction(id: "set-variable", name: "Set Variable", category: "Math", icon: "variable.fill", description: "Set a variable", parameters: []),
                ShortcutAction(id: "get-variable", name: "Get Variable", category: "Math", icon: "variable.fill", description: "Get a variable", parameters: []),
                ShortcutAction(id: "if", name: "If", category: "Math", icon: "arrow.triangle.branch", description: "Conditional logic", parameters: []),
                ShortcutAction(id: "show-result", name: "Show Result", category: "Math", icon: "info.circle.fill", description: "Display result", parameters: [])
            ])
        ]
    }
}
