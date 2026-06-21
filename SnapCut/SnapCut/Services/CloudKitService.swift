import Foundation
import CloudKit
import Combine

@MainActor
class CloudKitService: ObservableObject {
    static let shared = CloudKitService()

    @Published var isAvailable: Bool = false
    @Published var communityTemplates: [CommunityTemplate] = []
    @Published var isLoading: Bool = false

    private let containerID = "iCloud.com.zzoutuo.SnapCut"

    init() {
        checkAvailability()
    }

    private func checkAvailability() {
        isAvailable = FileManager.default.ubiquityIdentityToken != nil
    }

    func fetchCommunityTemplates(sortBy: String = "trending", search: String = "") async {
        isLoading = true
        defer { isLoading = false }

        if !isAvailable {
            communityTemplates = CommunityTemplate.sampleTemplates()
            return
        }

        let container = CKContainer(identifier: containerID)
        let database = container.publicCloudDatabase
        let query = CKQuery(recordType: "CommunityTemplate", predicate: NSPredicate(value: true))

        switch sortBy {
        case "trending":
            query.sortDescriptors = [NSSortDescriptor(key: "installCount", ascending: false)]
        case "newest":
            query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        case "topRated":
            query.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
        default:
            query.sortDescriptors = [NSSortDescriptor(key: "installCount", ascending: false)]
        }

        do {
            let result = try await database.records(matching: query, resultsLimit: 50)
            var templates: [CommunityTemplate] = []
            for (_, recordResult) in result.matchResults {
                if case .success(let record) = recordResult {
                    templates.append(CommunityTemplate(record: record))
                }
            }
            communityTemplates = templates
        } catch {
            communityTemplates = CommunityTemplate.sampleTemplates()
        }
    }

    func publishTemplate(name: String, yaml: String, description: String, category: String, icon: String, color: String) async -> Bool {
        if !isAvailable {
            return false
        }

        let container = CKContainer(identifier: containerID)
        let database = container.publicCloudDatabase
        let record = CKRecord(recordType: "CommunityTemplate")
        record["name"] = name as CKRecordValue
        record["yaml"] = yaml as CKRecordValue
        record["descriptionText"] = description as CKRecordValue
        record["category"] = category as CKRecordValue
        record["icon"] = icon as CKRecordValue
        record["color"] = color as CKRecordValue
        record["installCount"] = 0 as CKRecordValue
        record["rating"] = 0.0 as CKRecordValue
        record["authorID"] = "user" as CKRecordValue

        do {
            _ = try await database.save(record)
            return true
        } catch {
            return false
        }
    }

    func rateTemplate(id: String, rating: Int) async {
    }
}

struct CommunityTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let yaml: String
    let description: String
    let category: String
    let icon: String
    let color: String
    let installCount: Int
    let rating: Double
    let authorID: String

    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"] as? String ?? "Unknown"
        self.yaml = record["yaml"] as? String ?? ""
        self.description = record["descriptionText"] as? String ?? ""
        self.category = record["category"] as? String ?? "Other"
        self.icon = record["icon"] as? String ?? "square.stack.3d.up"
        self.color = record["color"] as? String ?? "8B5CF6"
        self.installCount = record["installCount"] as? Int ?? 0
        self.rating = record["rating"] as? Double ?? 0.0
        self.authorID = record["authorID"] as? String ?? "unknown"
    }

    init(id: String, name: String, yaml: String, description: String, category: String, icon: String, color: String, installCount: Int, rating: Double, authorID: String) {
        self.id = id
        self.name = name
        self.yaml = yaml
        self.description = description
        self.category = category
        self.icon = icon
        self.color = color
        self.installCount = installCount
        self.rating = rating
        self.authorID = authorID
    }

    static func sampleTemplates() -> [CommunityTemplate] {
        return [
            CommunityTemplate(id: "s1", name: "Morning Coffee Timer", yaml: "", description: "Start your day with a perfect brew timer", category: "Productivity", icon: "cup.and.saucer.fill", color: "8B5CF6", installCount: 1234, rating: 4.8, authorID: "barista_pro"),
            CommunityTemplate(id: "s2", name: "Workout Playlist", yaml: "", description: "Play your favorite workout music", category: "Health", icon: "figure.run", color: "3B82F6", installCount: 987, rating: 4.6, authorID: "fitness_fan"),
            CommunityTemplate(id: "s3", name: "Commute Helper", yaml: "", description: "Get traffic and weather for your commute", category: "Travel", icon: "car.fill", color: "10B981", installCount: 856, rating: 4.5, authorID: "commuter"),
            CommunityTemplate(id: "s4", name: "Photo Backup", yaml: "", description: "Backup latest photos to cloud", category: "Media", icon: "icloud.and.arrow.up.fill", color: "F59E0B", installCount: 743, rating: 4.7, authorID: "photo_enthusiast"),
            CommunityTemplate(id: "s5", name: "Meeting Notes", yaml: "", description: "Quick meeting notes template", category: "Productivity", icon: "note.text", color: "8B5CF6", installCount: 621, rating: 4.4, authorID: "productive_soul"),
            CommunityTemplate(id: "s6", name: "Water Reminder", yaml: "", description: "Stay hydrated with reminders", category: "Health", icon: "drop.fill", color: "3B82F6", installCount: 534, rating: 4.9, authorID: "health_coach")
        ]
    }
}
