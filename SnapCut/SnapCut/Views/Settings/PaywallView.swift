import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroSection

                    featuresSection

                    plansSection

                    restoreButton

                    legalLinks
                }
                .padding()
            }
            .navigationTitle("SnapCut Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await purchaseManager.loadProducts()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "8B5CF6"))

            Text("Unlock SnapCut Pro")
                .font(.largeTitle.bold())

            Text("Get unlimited AI generations, community access, and exclusive template packs")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: "infinity", title: "Unlimited AI", description: "Generate as many shortcuts as you want", color: "8B5CF6")
            FeatureRow(icon: "person.3.fill", title: "Community Access", description: "Share and install community shortcuts", color: "3B82F6")
            FeatureRow(icon: "gift.fill", title: "Premium Packs", description: "Unlock all template packs", color: "F59E0B")
            FeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Sync across all your devices", color: "10B981")
            FeatureRow(icon: "square.stack.3d.up.fill", title: "Save as Template", description: "Create reusable templates", color: "EC4899")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            ForEach(purchaseManager.products.filter { $0.id.contains("pro") }, id: \.id) { product in
                Button {
                    selectedProduct = product
                    Task { await purchase(product) }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.displayName)
                                .font(.headline)
                            Text(product.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(product.displayPrice)
                            .font(.headline)
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedProduct?.id == product.id ? Color(hex: "8B5CF6") : .clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing)
            }

            if isPurchasing {
                ProgressView("Processing...")
                    .tint(Color(hex: "8B5CF6"))
                    .padding()
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isPro {
                    dismiss()
                }
            }
        } label: {
            Label("Restore Purchases", systemImage: "arrow.clockwise")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy", destination: URL(string: "https://zzoutuo.github.io/SnapCut/privacy")!)
            Text("•").foregroundStyle(.tertiary)
            Link("Terms", destination: URL(string: "https://zzoutuo.github.io/SnapCut/terms")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        let success = await purchaseManager.purchase(product)
        isPurchasing = false
        if success {
            dismiss()
        } else {
            errorMessage = "Purchase failed. Please try again."
            showError = true
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color(hex: color))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(hex: "10B981"))
        }
    }
}
