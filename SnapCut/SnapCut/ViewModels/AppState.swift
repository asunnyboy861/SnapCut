import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isFirstLaunch: Bool
    @Published var selectedTab: Int = 0
    @Published var showPaywall: Bool = false

    private let defaults = UserDefaults.standard

    private init() {
        isFirstLaunch = defaults.bool(forKey: "isFirstLaunch") == false
    }

    func completeOnboarding() {
        isFirstLaunch = false
        defaults.set(true, forKey: "isFirstLaunch")
    }

    func selectTab(_ index: Int) {
        selectedTab = index
    }
}
