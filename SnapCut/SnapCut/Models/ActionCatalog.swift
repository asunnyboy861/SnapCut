import Foundation

struct ShortcutAction: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let icon: String
    let description: String
    let parameters: [ActionParameter]
}

struct ActionParameter: Codable, Hashable {
    let name: String
    let type: String
    let defaultValue: String
    let required: Bool
}

struct ActionCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let actions: [ShortcutAction]
}
