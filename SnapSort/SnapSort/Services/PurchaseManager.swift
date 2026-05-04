import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPremium: Bool = false
    var isLoading: Bool = false

    private var transactionListener: Task<Void, Never>?

    static let monthlyID = "com.zzoutuo.SnapSortAI.monthly"
    static let yearlyID = "com.zzoutuo.SnapSortAI.yearly"
    static let lifetimeID = "com.zzoutuo.SnapSortAI.lifetime"

    init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: [
                PurchaseManager.monthlyID,
                PurchaseManager.yearlyID,
                PurchaseManager.lifetimeID
            ])
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                isPremium = true
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {}
    }

    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
        isPremium = !purchasedIDs.isEmpty
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == PurchaseManager.monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == PurchaseManager.yearlyID }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == PurchaseManager.lifetimeID }
    }
}

enum StoreError: Error {
    case failedVerification
}
