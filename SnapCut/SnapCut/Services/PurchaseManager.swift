import Foundation
import StoreKit
import Combine

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var loadError: String?
    @Published var unlockedPacks: Set<String> = []

    private let productIds: Set<String> = [
        "com.zzoutuo.SnapCut.pro.monthly",
        "com.zzoutuo.SnapCut.pro.yearly",
        "com.zzoutuo.SnapCut.pack.holiday",
        "com.zzoutuo.SnapCut.pack.fitness",
        "com.zzoutuo.SnapCut.pack.travel"
    ]

    private let subscriptionIds: Set<String> = [
        "com.zzoutuo.SnapCut.pro.monthly",
        "com.zzoutuo.SnapCut.pro.yearly"
    ]

    private let packIds: Set<String> = [
        "com.zzoutuo.SnapCut.pack.holiday",
        "com.zzoutuo.SnapCut.pack.fitness",
        "com.zzoutuo.SnapCut.pack.travel"
    ]

    private var transactionListener: Task<Void, Never>?

    private init() {
        loadUnlockedPacks()
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIds)
            isLoading = false
        } catch {
            loadError = "Unable to load purchase options."
            isLoading = false
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await checkPurchased()
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func checkPurchased() async {
        var pro = false
        for id in subscriptionIds {
            if let result = await Transaction.currentEntitlement(for: id),
               case .verified(let transaction) = result,
               transaction.revocationDate == nil {
                pro = true
                break
            }
        }
        isPro = pro

        var packs: Set<String> = []
        for id in packIds {
            if let result = await Transaction.currentEntitlement(for: id),
               case .verified(let transaction) = result,
               transaction.revocationDate == nil {
                packs.insert(id)
            }
        }
        unlockedPacks = packs
        saveUnlockedPacks()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == "com.zzoutuo.SnapCut.pro.monthly" }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == "com.zzoutuo.SnapCut.pro.yearly" }
    }

    func packProduct(_ packId: String) -> Product? {
        products.first { $0.id == packId }
    }

    func isPackUnlocked(_ packId: String) -> Bool {
        unlockedPacks.contains(packId)
    }

    private func loadUnlockedPacks() {
        let saved = UserDefaults.standard.stringArray(forKey: "unlockedPacks") ?? []
        unlockedPacks = Set(saved)
    }

    private func saveUnlockedPacks() {
        UserDefaults.standard.set(Array(unlockedPacks), forKey: "unlockedPacks")
    }

    deinit {
        transactionListener?.cancel()
    }
}
