import Foundation
import SwiftUI
import SwiftData
import Combine
import UniformTypeIdentifiers

@MainActor
class MyShortcutsViewModel: ObservableObject {
    @Published var shortcuts: [UserShortcut] = []
    @Published var sortOption: SortOption = .dateCreated
    @Published var showImportPicker: Bool = false
    @Published var importedYAML: String?
    @Published var importedName: String?

    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case name = "Name"
        case mostUsed = "Most Used"
    }

    func fetchShortcuts(context: ModelContext) {
        let descriptor = FetchDescriptor<UserShortcut>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        shortcuts = (try? context.fetch(descriptor)) ?? []
        applySort()
    }

    func applySort() {
        switch sortOption {
        case .dateCreated:
            shortcuts.sort { $0.createdAt > $1.createdAt }
        case .name:
            shortcuts.sort { $0.name < $1.name }
        case .mostUsed:
            shortcuts.sort { $0.useCount > $1.useCount }
        }
    }

    func deleteShortcut(_ shortcut: UserShortcut, context: ModelContext) {
        context.delete(shortcut)
        try? context.save()
        fetchShortcuts(context: context)
    }

    func incrementUseCount(_ shortcut: UserShortcut, context: ModelContext) {
        shortcut.useCount += 1
        shortcut.lastUsedAt = .now
        try? context.save()
        fetchShortcuts(context: context)
    }

    func importShortcut(url: URL, context: ModelContext) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let name = url.deletingPathExtension().lastPathComponent

            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
               let yaml = plist["WFWorkflowYAML"] as? String {
                let shortcut = UserShortcut(
                    name: name,
                    yaml: yaml,
                    icon: "square.and.arrow.down",
                    color: "3B82F6",
                    source: "imported"
                )
                context.insert(shortcut)
                try? context.save()
                fetchShortcuts(context: context)
            } else {
                let yaml = String(data: data, encoding: .utf8) ?? ""
                let shortcut = UserShortcut(
                    name: name,
                    yaml: yaml,
                    icon: "square.and.arrow.down",
                    color: "3B82F6",
                    source: "imported"
                )
                context.insert(shortcut)
                try? context.save()
                fetchShortcuts(context: context)
            }
        } catch {
        }
    }

    func saveImportedShortcut(name: String, yaml: String, context: ModelContext) {
        let shortcut = UserShortcut(
            name: name,
            yaml: yaml,
            icon: "square.and.arrow.down",
            color: "3B82F6",
            source: "imported"
        )
        context.insert(shortcut)
        try? context.save()
        fetchShortcuts(context: context)
    }
}
