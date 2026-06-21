import SwiftUI
import SwiftData

struct TemplateDetailView: View {
    let template: ShortcutTemplate
    @StateObject private var compiler = ShortcutCompiler.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.modelContext) private var modelContext
    @State private var parameterValues: [String: String] = [:]
    @State private var showInstallSuccess = false
    @State private var showSaveAsTemplate = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header

                if !parameters.isEmpty {
                    parameterForm
                }

                stepsPreview

                installButton
            }
            .padding()
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Installed!", isPresented: $showInstallSuccess) {
            Button("OK") { }
        } message: {
            Text("Your shortcut has been sent to the Shortcuts app.")
        }
        .sheet(isPresented: $showSaveAsTemplate) {
            SaveAsTemplateView(yaml: template.yaml)
        }
    }

    private var parameters: [TemplateParameter] {
        TemplateViewModel().parseParameters(template.parametersJSON)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: template.icon)
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: template.color))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.title2.bold())
                Text(template.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var parameterForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parameters")
                .font(.headline)

            ForEach(parameters) { param in
                VStack(alignment: .leading, spacing: 4) {
                    Text(param.label)
                        .font(.subheadline.bold())
                    TextField(param.placeholder, text: Binding(
                        get: { parameterValues[param.name] ?? param.defaultValue },
                        set: { parameterValues[param.name] = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var stepsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Steps Preview")
                .font(.headline)

            let yaml = compiler.substituteParameters(yaml: template.yaml, parameters: parameterValues)
            let steps = compiler.parseYAML(yaml)

            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: template.color))
                        .frame(width: 24, height: 24)
                        .background(Color(hex: template.color).opacity(0.2))
                        .clipShape(Circle())

                    Image(systemName: step.icon)
                        .foregroundStyle(Color(hex: template.color))

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

    private var installButton: some View {
        Button {
            let yaml = compiler.substituteParameters(yaml: template.yaml, parameters: parameterValues)
            let name = template.name
            if let url = compiler.installShortcutURL(name: name) {
                UIApplication.shared.open(url)
            }
            let shortcut = UserShortcut(
                name: name,
                yaml: yaml,
                icon: template.icon,
                color: template.color,
                source: "template"
            )
            modelContext.insert(shortcut)
            try? modelContext.save()
            showInstallSuccess = true
        } label: {
            HStack {
                Image(systemName: "arrow.down.app.fill")
                Text("Install Template")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "10B981"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SaveAsTemplateView: View {
    let yaml: String
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var category: String = "Productivity"
    @State private var icon: String = "square.stack.3d.up"
    @State private var color: String = "8B5CF6"
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared

    let categories = ["Smart Home", "Productivity", "Health", "Social", "Travel", "Finance", "Media", "Device"]
    let icons = ["wand.and.stars", "house.fill", "figure.run", "message.fill", "car.fill", "dollarsign.circle.fill", "photo.fill", "gearshape.fill"]
    let colors = ["8B5CF6", "3B82F6", "10B981", "F59E0B", "EF4444", "EC4899"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Info") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section("Appearance") {
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { ic in
                            Image(systemName: ic).tag(ic)
                        }
                    }

                    Picker("Color", selection: $color) {
                        ForEach(colors, id: \.self) { c in
                            HStack {
                                Circle()
                                    .fill(Color(hex: c))
                                    .frame(width: 20, height: 20)
                                Text(c)
                            }
                            .tag(c)
                        }
                    }
                }

                if !purchaseManager.isPro {
                    Section {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color(hex: "F59E0B"))
                            Text("Save as Template is a Pro feature")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let template = ShortcutTemplate(
                            name: name,
                            yaml: yaml,
                            templateDescription: description,
                            category: category,
                            icon: icon,
                            color: color,
                            isBuiltIn: false,
                            authorID: "user"
                        )
                        modelContext.insert(template)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || !purchaseManager.isPro)
                }
            }
        }
    }
}
