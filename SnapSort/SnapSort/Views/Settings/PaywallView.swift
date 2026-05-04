import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false

    enum PlanType: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresList
                    planSelector
                    subscribeButton
                    restoreButton
                    termsText
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await purchaseManager.loadProducts()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock SnapSort AI Premium")
                .font(.title2)
                .fontWeight(.bold)

            Text("Get the most out of your screenshot management")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: "folder.fill", text: "All 13 smart categories")
            FeatureRow(icon: "magnifyingglass", text: "Unlimited OCR search")
            FeatureRow(icon: "faceid", text: "Face ID protection")
            FeatureRow(icon: "doc.on.doc.fill", text: "Duplicate detection")
            FeatureRow(icon: "square.and.arrow.up.fill", text: "Batch operations")
            FeatureRow(icon: "chart.bar.fill", text: "Storage analytics")
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var planSelector: some View {
        VStack(spacing: 10) {
            ForEach(PlanType.allCases, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan,
                    purchaseManager: purchaseManager
                )
                .onTapGesture {
                    withAnimation { selectedPlan = plan }
                }
            }
        }
    }

    private var subscribeButton: some View {
        Button {
            purchaseSelectedPlan()
        } label: {
            if isPurchasing {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Subscribe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color.blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(isPurchasing)
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isPremium {
                    dismiss()
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.blue)
    }

    private var termsText: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    private func purchaseSelectedPlan() {
        Task {
            isPurchasing = true
            var success = false

            switch selectedPlan {
            case .monthly:
                if let product = purchaseManager.monthlyProduct {
                    success = await purchaseManager.purchase(product)
                }
            case .yearly:
                if let product = purchaseManager.yearlyProduct {
                    success = await purchaseManager.purchase(product)
                }
            case .lifetime:
                if let product = purchaseManager.lifetimeProduct {
                    success = await purchaseManager.purchase(product)
                }
            }

            isPurchasing = false
            if success { dismiss() }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .font(.caption)
        }
    }
}

struct PlanCard: View {
    let plan: PaywallView.PlanType
    let isSelected: Bool
    let purchaseManager: PurchaseManager

    private var priceText: String {
        switch plan {
        case .monthly:
            if let product = purchaseManager.monthlyProduct {
                return "\(product.displayPrice)/month"
            }
            return "$1.99/month"
        case .yearly:
            if let product = purchaseManager.yearlyProduct {
                return "\(product.displayPrice)/year"
            }
            return "$9.99/year"
        case .lifetime:
            if let product = purchaseManager.lifetimeProduct {
                return "\(product.displayPrice) once"
            }
            return "$29.99 once"
        }
    }

    private var savingsText: String? {
        switch plan {
        case .yearly: return "58% savings"
        case .lifetime: return "Best value"
        default: return nil
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plan.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if let savings = savingsText {
                        Text(savings)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
                Text(priceText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .blue : .secondary)
                .font(.title3)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
        )
    }
}
