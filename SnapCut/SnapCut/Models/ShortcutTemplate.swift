import Foundation
import SwiftData

@Model
final class ShortcutTemplate {
    var id: UUID
    var name: String
    var yaml: String
    var templateDescription: String
    var category: String
    var icon: String
    var color: String
    var isBuiltIn: Bool
    var authorID: String
    var parametersJSON: String
    var packID: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        yaml: String,
        templateDescription: String,
        category: String,
        icon: String = "square.stack.3d.up",
        color: String = "8B5CF6",
        isBuiltIn: Bool = true,
        authorID: String = "system",
        parametersJSON: String = "[]",
        packID: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.yaml = yaml
        self.templateDescription = templateDescription
        self.category = category
        self.icon = icon
        self.color = color
        self.isBuiltIn = isBuiltIn
        self.authorID = authorID
        self.parametersJSON = parametersJSON
        self.packID = packID
        self.createdAt = createdAt
    }
}

struct TemplateParameter: Codable, Identifiable {
    var id: String
    var name: String
    var placeholder: String
    var type: ParameterType
    var defaultValue: String
    var label: String

    init(
        id: String = UUID().uuidString,
        name: String,
        placeholder: String,
        type: ParameterType = .text,
        defaultValue: String = "",
        label: String
    ) {
        self.id = id
        self.name = name
        self.placeholder = placeholder
        self.type = type
        self.defaultValue = defaultValue
        self.label = label
    }

    enum ParameterType: String, Codable {
        case text
        case number
        case toggle
        case time
        case location
        case contact
        case app
    }
}
