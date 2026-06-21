import SwiftUI
import SwiftData

struct TemplateGalleryView: View {
    @StateObject private var viewModel = TemplateViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilter

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.filteredTemplates) { template in
                            NavigationLink {
                                TemplateDetailView(template: template)
                            } label: {
                                TemplateCard(template: template)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .searchable(text: $viewModel.searchText, prompt: "Search templates")
            }
            .navigationTitle("Templates")
            .onAppear {
                viewModel.loadBuiltInTemplates(context: modelContext)
                viewModel.fetchTemplates(context: modelContext)
            }
            .onChange(of: viewModel.searchText) {
                viewModel.applyFilters()
            }
            .onChange(of: viewModel.selectedCategory) {
                viewModel.applyFilters()
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.bold())
                            .foregroundStyle(viewModel.selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedCategory == category
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
}

struct TemplateCard: View {
    let template: ShortcutTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: template.color))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                if !template.isBuiltIn {
                    Text("MY")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(hex: "8B5CF6"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "8B5CF6").opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Text(template.name)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(template.templateDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(template.category)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TemplateGalleryView()
}
