import SwiftUI

struct TemplatePackView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    let packs: [TemplatePack] = [
        TemplatePack(
            id: "com.zzoutuo.SnapCut.pack.holiday",
            name: "Holiday Pack",
            description: "Holiday-themed shortcuts: Christmas lights, New Year countdown, Thanksgiving gratitude, Halloween sounds.",
            icon: "gift.fill",
            color: "EF4444",
            templates: ["Christmas Lights Timer", "New Year Countdown", "Thanksgiving Gratitude", "Halloween Sounds"]
        ),
        TemplatePack(
            id: "com.zzoutuo.SnapCut.pack.fitness",
            name: "Fitness Pack",
            description: "Fitness shortcuts: Workout starter, run tracker, water reminder, meditation timer.",
            icon: "figure.run",
            color: "10B981",
            templates: ["Workout Starter", "Run Tracker", "Water Reminder", "Meditation Timer"]
        ),
        TemplatePack(
            id: "com.zzoutuo.SnapCut.pack.travel",
            name: "Travel Pack",
            description: "Travel shortcuts: Packing list, currency converter, language translator, trip itinerary.",
            icon: "airplane",
            color: "3B82F6",
            templates: ["Packing List", "Currency Converter", "Language Translator", "Trip Itinerary"]
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(packs) { pack in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: pack.icon)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(Color(hex: pack.color))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pack.name)
                                    .font(.headline)
                                Text("$0.99")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()

                            if purchaseManager.isPackUnlocked(pack.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: "10B981"))
                                    .font(.title2)
                            } else {
                                Button {
                                    Task {
                                        if let product = purchaseManager.packProduct(pack.id) {
                                            _ = await purchaseManager.purchase(product)
                                        }
                                    }
                                } label: {
                                    Text("Buy")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "8B5CF6"))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text(pack.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if purchaseManager.isPackUnlocked(pack.id) {
                            ForEach(pack.templates, id: \.self) { templateName in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hex: "10B981"))
                                    Text(templateName)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Template Packs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct TemplatePack: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
    let templates: [String]
}
