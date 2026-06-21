import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class TemplateViewModel: ObservableObject {
    @Published var templates: [ShortcutTemplate] = []
    @Published var filteredTemplates: [ShortcutTemplate] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "All"
    @Published var isLoading: Bool = false

    let categories = ["All", "Smart Home", "Productivity", "Health", "Social", "Travel", "Finance", "Media", "Device"]

    private let purchaseManager = PurchaseManager.shared

    func loadBuiltInTemplates(context: ModelContext) {
        let builtIn = BuiltInTemplates.all
        for template in builtIn {
            let templateName = template.name
            let descriptor = FetchDescriptor<ShortcutTemplate>(
                predicate: #Predicate { $0.name == templateName && $0.isBuiltIn }
            )
            let existing = (try? context.fetch(descriptor)) ?? []
            if existing.isEmpty {
                let entity = ShortcutTemplate(
                    name: template.name,
                    yaml: template.yaml,
                    templateDescription: template.description,
                    category: template.category,
                    icon: template.icon,
                    color: template.color,
                    isBuiltIn: true,
                    parametersJSON: template.parametersJSON
                )
                context.insert(entity)
            }
        }
        try? context.save()
        fetchTemplates(context: context)
    }

    func fetchTemplates(context: ModelContext) {
        let descriptor = FetchDescriptor<ShortcutTemplate>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        templates = (try? context.fetch(descriptor)) ?? []
        applyFilters()
    }

    func applyFilters() {
        var filtered = templates

        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            let lower = searchText.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(lower) ||
                $0.templateDescription.lowercased().contains(lower) ||
                $0.category.lowercased().contains(lower)
            }
        }

        filteredTemplates = filtered
    }

    func isPackLocked(_ packID: String) -> Bool {
        !purchaseManager.isPackUnlocked(packID)
    }

    func saveAsTemplate(name: String, yaml: String, description: String, category: String, icon: String, color: String, parametersJSON: String, context: ModelContext) {
        let template = ShortcutTemplate(
            name: name,
            yaml: yaml,
            templateDescription: description,
            category: category,
            icon: icon,
            color: color,
            isBuiltIn: false,
            authorID: "user",
            parametersJSON: parametersJSON
        )
        context.insert(template)
        try? context.save()
        fetchTemplates(context: context)
    }

    func parseParameters(_ json: String) -> [TemplateParameter] {
        guard let data = json.data(using: .utf8),
              let params = try? JSONDecoder().decode([TemplateParameter].self, from: data) else {
            return []
        }
        return params
    }
}

struct BuiltInTemplates {
    static let all: [BuiltInTemplate] = [
        BuiltInTemplate(
            name: "Morning Routine",
            description: "Start your day with weather, calendar, and focus music",
            category: "Productivity",
            icon: "sun.max.fill",
            color: "F59E0B",
            yaml: """
name: Morning Routine
icon: sun.max.fill
color: "F59E0B"
steps:
  - action: Get Weather
    icon: cloud.sun.fill
    summary: "Get today's weather forecast"
  - action: Add New Event
    icon: calendar
    summary: "Check today's calendar events"
  - action: Set Volume
    icon: speaker.wave.2.fill
    parameters:
      volume: "30"
    summary: "Set volume to 30%"
  - action: Play Sound
    icon: play.circle.fill
    summary: "Play morning playlist"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Arrive Home",
            description: "Turn on lights, connect to Wi-Fi, and play music when you get home",
            category: "Smart Home",
            icon: "house.fill",
            color: "8B5CF6",
            yaml: """
name: Arrive Home
icon: house.fill
color: "8B5CF6"
steps:
  - action: Get Current Location
    icon: location.fill
    summary: "Check current location"
  - action: Set Wi-Fi
    icon: wifi
    summary: "Enable Wi-Fi"
  - action: Set Appearance
    icon: sun.max.fill
    summary: "Set appearance to dark mode"
  - action: Play Sound
    icon: play.circle.fill
    summary: "Play welcome home music"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Workout Starter",
            description: "Start workout, play music, and set Do Not Disturb",
            category: "Health",
            icon: "figure.run",
            color: "10B981",
            yaml: """
name: Workout Starter
icon: figure.run
color: "10B981"
steps:
  - action: Set Do Not Disturb
    icon: moon.fill
    summary: "Enable Do Not Disturb"
  - action: Set Volume
    icon: speaker.wave.3.fill
    parameters:
      volume: "80"
    summary: "Set volume to 80%"
  - action: Play Sound
    icon: play.circle.fill
    summary: "Play workout playlist"
  - action: Start Timer
    icon: timer
    parameters:
      seconds: "1800"
    summary: "Start 30-minute workout timer"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Bedtime Mode",
            description: "Set low power mode, dim brightness, and enable Do Not Disturb",
            category: "Device",
            icon: "moon.zzz.fill",
            color: "3B82F6",
            yaml: """
name: Bedtime Mode
icon: moon.zzz.fill
color: "3B82F6"
steps:
  - action: Set Low Power Mode
    icon: bolt.fill
    summary: "Enable low power mode"
  - action: Set Brightness
    icon: sun.max.fill
    parameters:
      brightness: "10"
    summary: "Dim screen brightness"
  - action: Set Do Not Disturb
    icon: moon.fill
    summary: "Enable Do Not Disturb"
  - action: Set Appearance
    icon: circle.lefthalf.filled
    summary: "Set dark mode"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Quick Message",
            description: "Send a pre-written message to a contact",
            category: "Social",
            icon: "message.fill",
            color: "8B5CF6",
            yaml: """
name: Quick Message
icon: message.fill
color: "8B5CF6"
steps:
  - action: Send Message
    icon: message.fill
    parameters:
      contact: "{{contact}}"
      message: "{{message}}"
    summary: "Send message to contact"
""",
            parametersJSON: "[{\"id\":\"1\",\"name\":\"contact\",\"placeholder\":\"Contact name\",\"type\":\"contact\",\"defaultValue\":\"\",\"label\":\"Recipient\"},{\"id\":\"2\",\"name\":\"message\",\"placeholder\":\"Message text\",\"type\":\"text\",\"defaultValue\":\"\",\"label\":\"Message\"}]"
        ),
        BuiltInTemplate(
            name: "Commute Helper",
            description: "Get traffic, weather, and ETA for your commute",
            category: "Travel",
            icon: "car.fill",
            color: "10B981",
            yaml: """
name: Commute Helper
icon: car.fill
color: "10B981"
steps:
  - action: Get Current Location
    icon: location.fill
    summary: "Get current location"
  - action: Get Directions
    icon: arrow.triangle.turn.up.right.diamond.fill
    parameters:
      destination: "{{destination}}"
    summary: "Get directions to work"
  - action: Get Travel Time
    icon: clock.arrow.circlepath
    summary: "Check travel time"
  - action: Get Weather
    icon: cloud.sun.fill
    summary: "Get weather at destination"
""",
            parametersJSON: "[{\"id\":\"1\",\"name\":\"destination\",\"placeholder\":\"Work address\",\"type\":\"location\",\"defaultValue\":\"\",\"label\":\"Destination\"}]"
        ),
        BuiltInTemplate(
            name: "Photo Backup",
            description: "Backup your latest photos to iCloud",
            category: "Media",
            icon: "icloud.and.arrow.up.fill",
            color: "F59E0B",
            yaml: """
name: Photo Backup
icon: icloud.and.arrow.up.fill
color: "F59E0B"
steps:
  - action: Get Latest Photos
    icon: photo.on.rectangle.angled
    parameters:
      count: "10"
    summary: "Get latest 10 photos"
  - action: Save File
    icon: folder.badge.plus
    summary: "Save photos to backup folder"
  - action: Show Result
    icon: checkmark.circle.fill
    summary: "Show backup complete message"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Expense Tracker",
            description: "Log an expense with amount and category",
            category: "Finance",
            icon: "dollarsign.circle.fill",
            color: "10B981",
            yaml: """
name: Expense Tracker
icon: dollarsign.circle.fill
color: "10B981"
steps:
  - action: Text
    icon: text.alignleft
    parameters:
      text: "{{amount}}"
    summary: "Enter expense amount"
  - action: Add New Reminder
    icon: checklist
    summary: "Create expense reminder"
  - action: Copy to Clipboard
    icon: doc.on.doc.fill
    summary: "Copy expense details"
""",
            parametersJSON: "[{\"id\":\"1\",\"name\":\"amount\",\"placeholder\":\"$0.00\",\"type\":\"number\",\"defaultValue\":\"\",\"label\":\"Amount\"}]"
        ),
        BuiltInTemplate(
            name: "Focus Timer",
            description: "25-minute Pomodoro timer with Do Not Disturb",
            category: "Productivity",
            icon: "timer",
            color: "8B5CF6",
            yaml: """
name: Focus Timer
icon: timer
color: "8B5CF6"
steps:
  - action: Set Do Not Disturb
    icon: moon.fill
    summary: "Enable Do Not Disturb"
  - action: Start Timer
    icon: timer
    parameters:
      seconds: "1500"
    summary: "Start 25-minute focus timer"
  - action: Show Result
    icon: checkmark.circle.fill
    summary: "Show focus session complete"
""",
            parametersJSON: "[]"
        ),
        BuiltInTemplate(
            name: "Weather Check",
            description: "Get current weather and forecast for your location",
            category: "Device",
            icon: "cloud.sun.fill",
            color: "3B82F6",
            yaml: """
name: Weather Check
icon: cloud.sun.fill
color: "3B82F6"
steps:
  - action: Get Current Location
    icon: location.fill
    summary: "Get current location"
  - action: Get Weather
    icon: cloud.sun.fill
    summary: "Get current weather"
  - action: Get Weather Forecast
    icon: cloud.sun.rain.fill
    summary: "Get weather forecast"
  - action: Speak Text
    icon: speaker.wave.2.fill
    summary: "Speak weather summary"
""",
            parametersJSON: "[]"
        )
    ]
}

struct BuiltInTemplate {
    let name: String
    let description: String
    let category: String
    let icon: String
    let color: String
    let yaml: String
    let parametersJSON: String
}
