import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct MyShortcutsView: View {
    @StateObject private var viewModel = MyShortcutsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showImportPicker = false
    @State private var showTemplatePacks = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.shortcuts.isEmpty {
                    emptyState
                } else {
                    shortcutsList
                }
            }
            .navigationTitle("My Cuts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showImportPicker = true
                        } label: {
                            Label("Import Shortcut", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            showTemplatePacks = true
                        } label: {
                            Label("Template Packs", systemImage: "gift.fill")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "8B5CF6"))
                    }
                }
            }
            .onAppear {
                viewModel.fetchShortcuts(context: modelContext)
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [UTType(filenameExtension: "shortcut") ?? .data, .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.importShortcut(url: url, context: modelContext)
                    }
                case .failure:
                    break
                }
            }
            .sheet(isPresented: $showTemplatePacks) {
                TemplatePackView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("No shortcuts yet")
                .font(.title3.bold())

            Text("Create your first shortcut with AI or import an existing one")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                AppState.shared.selectTab(0)
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Create with AI")
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

    private var shortcutsList: some View {
        List {
            Picker("Sort", selection: $viewModel.sortOption) {
                ForEach(MyShortcutsViewModel.SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .onChange(of: viewModel.sortOption) {
                viewModel.applySort()
            }

            ForEach(viewModel.shortcuts) { shortcut in
                NavigationLink {
                    ShortcutDetailView(shortcut: shortcut)
                } label: {
                    ShortcutRow(shortcut: shortcut)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let shortcut = viewModel.shortcuts[index]
                    viewModel.deleteShortcut(shortcut, context: modelContext)
                }
            }
        }
    }
}

struct ShortcutRow: View {
    let shortcut: UserShortcut

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: shortcut.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: shortcut.color))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.name)
                    .font(.subheadline.bold())
                HStack(spacing: 8) {
                    Text(shortcut.source.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(shortcut.createdAt.formatted(.dateTime.month().day().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if shortcut.useCount > 0 {
                        Text("•")
                            .foregroundStyle(.tertiary)
                        Text("\(shortcut.useCount) uses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ShortcutDetailView: View {
    let shortcut: UserShortcut
    @StateObject private var compiler = ShortcutCompiler.shared
    @Environment(\.modelContext) private var modelContext
    @State private var showInstallSuccess = false
    @State private var showSaveAsTemplate = false
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                stepsList

                actionButtons
            }
            .padding()
        }
        .navigationTitle(shortcut.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Installed!", isPresented: $showInstallSuccess) {
            Button("OK") { }
        } message: {
            Text("Your shortcut has been sent to the Shortcuts app.")
        }
        .sheet(isPresented: $showSaveAsTemplate) {
            SaveAsTemplateView(yaml: shortcut.yaml)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: shortcut.icon)
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: shortcut.color))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.name)
                    .font(.title2.bold())
                Text("Created \(shortcut.createdAt.formatted(.dateTime.month().day().year()))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if shortcut.useCount > 0 {
                    Text("Used \(shortcut.useCount) times")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private var stepsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Steps")
                .font(.headline)

            let steps = compiler.parseYAML(shortcut.yaml)
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: shortcut.color))
                        .frame(width: 24, height: 24)
                        .background(Color(hex: shortcut.color).opacity(0.2))
                        .clipShape(Circle())

                    Image(systemName: step.icon)
                        .foregroundStyle(Color(hex: shortcut.color))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.actionName)
                            .font(.subheadline.bold())
                        Text(step.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if let url = compiler.installShortcutURL(name: shortcut.name) {
                    UIApplication.shared.open(url)
                }
                viewModel_incrementUse()
                showInstallSuccess = true
            } label: {
                HStack {
                    Image(systemName: "arrow.down.app.fill")
                    Text("Install to Shortcuts")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "10B981"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                showSaveAsTemplate = true
            } label: {
                HStack {
                    Image(systemName: "square.stack.3d.up")
                    Text("Save as Template")
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color(hex: "8B5CF6"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "8B5CF6").opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func viewModel_incrementUse() {
        shortcut.useCount += 1
        shortcut.lastUsedAt = .now
        try? modelContext.save()
    }
}

#Preview {
    MyShortcutsView()
}
