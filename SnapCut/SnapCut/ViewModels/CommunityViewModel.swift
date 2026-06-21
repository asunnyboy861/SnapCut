import Foundation
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var templates: [CommunityTemplate] = []
    @Published var isLoading: Bool = false
    @Published var sortBy: String = "trending"
    @Published var searchText: String = ""

    private let cloudKitService = CloudKitService.shared
    private let purchaseManager = PurchaseManager.shared

    var canInstall: Bool {
        purchaseManager.isPro || dailyInstallCount < 5
    }

    private var dailyInstallCount: Int {
        let dateKey = "installDate_\(Date().formatted(.dateTime.year().month().day()))"
        return UserDefaults.standard.integer(forKey: dateKey)
    }

    func incrementInstallCount() {
        let dateKey = "installDate_\(Date().formatted(.dateTime.year().month().day()))"
        let current = UserDefaults.standard.integer(forKey: dateKey)
        UserDefaults.standard.set(current + 1, forKey: dateKey)
    }

    func fetchTemplates() async {
        isLoading = true
        await cloudKitService.fetchCommunityTemplates(sortBy: sortBy, search: searchText)
        templates = cloudKitService.communityTemplates
        isLoading = false
    }

    func publishTemplate(name: String, yaml: String, description: String, category: String, icon: String, color: String) async -> Bool {
        guard purchaseManager.isPro else { return false }
        return await cloudKitService.publishTemplate(
            name: name,
            yaml: yaml,
            description: description,
            category: category,
            icon: icon,
            color: color
        )
    }
}
