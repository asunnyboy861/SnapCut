import Foundation
import Combine

struct ShortcutStep: Identifiable, Hashable {
    let id: UUID
    var actionName: String
    var icon: String
    var parameters: [String: String]
    var summary: String

    init(id: UUID = UUID(), actionName: String, icon: String = "gearshape", parameters: [String: String] = [:], summary: String = "") {
        self.id = id
        self.actionName = actionName
        self.icon = icon
        self.parameters = parameters
        self.summary = summary.isEmpty ? actionName : summary
    }
}

@MainActor
class ShortcutCompiler: ObservableObject {
    static let shared = ShortcutCompiler()

    func generateYAML(name: String, steps: [ShortcutStep]) -> String {
        var yaml = "name: \(name)\n"
        yaml += "icon: wand.and.stars\n"
        yaml += "color: \"8B5CF6\"\n"
        yaml += "steps:\n"
        for step in steps {
            yaml += "  - action: \(step.actionName)\n"
            yaml += "    icon: \(step.icon)\n"
            if !step.parameters.isEmpty {
                yaml += "    parameters:\n"
                for (key, value) in step.parameters {
                    yaml += "      \(key): \"\(value)\"\n"
                }
            }
            yaml += "    summary: \"\(step.summary)\"\n"
        }
        return yaml
    }

    func parseYAML(_ yaml: String) -> [ShortcutStep] {
        var steps: [ShortcutStep] = []
        var currentAction = ""
        var currentIcon = "gearshape"
        var currentSummary = ""
        var currentParams: [String: String] = [:]
        var inParameters = false

        let lines = yaml.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- action:") {
                if !currentAction.isEmpty {
                    steps.append(ShortcutStep(actionName: currentAction, icon: currentIcon, parameters: currentParams, summary: currentSummary))
                }
                currentAction = trimmed.replacingOccurrences(of: "- action:", with: "").trimmingCharacters(in: .whitespaces)
                currentIcon = "gearshape"
                currentSummary = ""
                currentParams = [:]
                inParameters = false
            } else if trimmed.hasPrefix("icon:") {
                currentIcon = trimmed.replacingOccurrences(of: "icon:", with: "").trimmingCharacters(in: .whitespaces)
                inParameters = false
            } else if trimmed.hasPrefix("summary:") {
                currentSummary = trimmed.replacingOccurrences(of: "summary:", with: "").trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                inParameters = false
            } else if trimmed.hasPrefix("parameters:") {
                inParameters = true
            } else if inParameters, trimmed.contains(":") {
                let parts = trimmed.components(separatedBy: ":")
                if parts.count >= 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                    currentParams[key] = value
                }
            }
        }
        if !currentAction.isEmpty {
            steps.append(ShortcutStep(actionName: currentAction, icon: currentIcon, parameters: currentParams, summary: currentSummary))
        }
        return steps
    }

    func substituteParameters(yaml: String, parameters: [String: String]) -> String {
        var result = yaml
        for (key, value) in parameters {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }

    func createShortcutFile(name: String, yaml: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = name.replacingOccurrences(of: " ", with: "_")
        let fileURL = tempDir.appendingPathComponent("\(fileName).shortcut")

        let shortcutData = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>WFWorkflowName</key>
            <string>\(name)</string>
            <key>WFWorkflowYAML</key>
            <string>\(yaml)</string>
        </dict>
        </plist>
        """

        do {
            try shortcutData.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    func installShortcutURL(name: String) -> URL? {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        return URL(string: "shortcuts://create-shortcut?name=\(encoded)")
    }
}
