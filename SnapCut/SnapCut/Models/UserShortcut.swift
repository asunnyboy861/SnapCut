import Foundation
import SwiftData

@Model
final class UserShortcut {
    var id: UUID
    var name: String
    var yaml: String
    var icon: String
    var color: String
    var source: String
    var createdAt: Date
    var updatedAt: Date
    var lastUsedAt: Date?
    var useCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        yaml: String,
        icon: String = "wand.and.stars",
        color: String = "8B5CF6",
        source: String = "created",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        lastUsedAt: Date? = nil,
        useCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.yaml = yaml
        self.icon = icon
        self.color = color
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastUsedAt = lastUsedAt
        self.useCount = useCount
    }
}
