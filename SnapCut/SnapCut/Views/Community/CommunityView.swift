import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPublishSheet = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sortSelector

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading community...")
                        .tint(Color(hex: "8B5CF6"))
                    Spacer()
                } else if viewModel.templates.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.templates) { template in
                                CommunityCard(template: template) {
                                    Task { await installTemplate(template) }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Community")
            .searchable(text: $viewModel.searchText, prompt: "Search community")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if purchaseManager.isPro {
                            showPublishSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }
                    .accessibilityLabel("Publish shortcut")
                }
            }
            .sheet(isPresented: $showPublishSheet) {
                PublishTemplateView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .task {
                await viewModel.fetchTemplates()
            }
            .onChange(of: viewModel.searchText) {
                Task { await viewModel.fetchTemplates() }
            }
        }
    }

    private var sortSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["trending", "new", "popular"], id: \.self) { sort in
                    Button {
                        viewModel.sortBy = sort
                        Task { await viewModel.fetchTemplates() }
                    } label: {
                        Text(sort.capitalized)
                            .font(.subheadline.bold())
                            .foregroundStyle(viewModel.sortBy == sort ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.sortBy == sort
                                ? Color(hex: "8B5CF6")
                                : Color(.secondarySystemBackground)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("No community shortcuts yet")
                .font(.title3.bold())

            Text("Be the first to share your shortcut with the world!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                if purchaseManager.isPro {
                    showPublishSheet = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Publish a Shortcut")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "8B5CF6"))
                .clipShape(Capsule())
            }
        }
        .padding()
    }

    private func installTemplate(_ template: CommunityTemplate) async {
        guard viewModel.canInstall else {
            showPaywall = true
            return
        }
        viewModel.incrementInstallCount()
        if let url = URL(string: "shortcuts://import-workflow?name=\(template.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            await UIApplication.shared.open(url)
        }
    }
}

struct CommunityCard: View {
    let template: CommunityTemplate
    let onInstall: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color(hex: template.color))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.headline)
                    Text("by \(template.authorID)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                VStack(spacing: 2) {
                    Image(systemName: "arrow.down.app.fill")
                        .foregroundStyle(Color(hex: "8B5CF6"))
                    Text("\(template.installCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(template.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(template.category)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                Spacer()

                Button {
                    onInstall()
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.app.fill")
                        Text("Install")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "10B981"))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PublishTemplateView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var category = "Productivity"
    @State private var icon = "wand.and.stars"
    @State private var color = "8B5CF6"
    @State private var yaml = ""
    @State private var isPublishing = false
    @State private var showError = false
    @State private var errorMessage = ""

    let categories = ["Smart Home", "Productivity", "Health", "Social", "Travel", "Finance", "Media", "Device"]
    let icons = ["wand.and.stars", "house.fill", "figure.run", "message.fill", "car.fill", "dollarsign.circle.fill", "photo.fill", "gearshape.fill"]
    let colors = ["8B5CF6", "3B82F6", "10B981", "F59E0B", "EF4444", "EC4899"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Shortcut") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { Image(systemName: $0).tag($0) }
                    }
                    Picker("Color", selection: $color) {
                        ForEach(colors, id: \.self) { color in
                            HStack {
                                Circle().fill(Color(hex: color)).frame(width: 20, height: 20)
                                Text(color)
                            }.tag(color)
                        }
                    }
                }

                Section("YAML Content") {
                    TextEditor(text: $yaml)
                        .frame(minHeight: 200)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .navigationTitle("Publish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        Task { await publish() }
                    }
                    .disabled(name.isEmpty || yaml.isEmpty || isPublishing)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func publish() async {
        isPublishing = true
        let success = await viewModel.publishTemplate(
            name: name,
            yaml: yaml,
            description: description,
            category: category,
            icon: icon,
            color: color
        )
        isPublishing = false
        if success {
            dismiss()
        } else {
            errorMessage = "Failed to publish. Please try again."
            showError = true
        }
    }
}

#Preview {
    CommunityView()
}
