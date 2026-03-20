import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \TaskCategory.name) private var categories: [TaskCategory]

    @State private var showingAddCategory = false
    @State private var editingCategory: TaskCategory?
    @State private var showingDeleteConfirmation = false
    @State private var categoryToDelete: TaskCategory?

    var body: some View {
        NavigationStack {
            listContent
                .navigationTitle("Manage Categories")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddCategory) {
                    AddCategoryView()
                }
                .sheet(item: $editingCategory) { category in
                    EditCategoryView(category: category)
                }
                .alert("Delete Category", isPresented: $showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        deleteCategory(categoryToDelete)
                    }
                } message: {
                    let taskCount = taskCount(for: categoryToDelete)
                    if taskCount > 0 {
                        Text("This category contains \(taskCount) task(s). The tasks will be uncategorized.")
                    } else {
                        Text("Are you sure you want to delete this category?")
                    }
                }
        }
    }

    // MARK: - List Content

    @ViewBuilder
    private var listContent: some View {
        if categories.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(categories) { category in
                    categoryRow(for: category)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Categories")
                .font(.title2.bold())

            Text("Tap + to create your first category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func categoryRow(for category: TaskCategory) -> some View {
        HStack(spacing: 12) {
            categoryIcon(for: category)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Text("\(taskCount(for: category)) tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                editingCategory = category
            } label: {
                Image(systemName: "pencil")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Button {
                categoryToDelete = category
                showingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private func categoryIcon(for category: TaskCategory) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.2))
                .frame(width: 44, height: 44)

            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(category.color)
        }
    }

    // MARK: - Helpers

    private func taskCount(for category: TaskCategory?) -> Int {
        guard let category = category else { return 0 }
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { task in
                task.category?.id == category.id
            }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    private func deleteCategory(_ category: TaskCategory?) {
        guard let category = category else { return }

        // Update tasks to remove category reference
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { task in
                task.category?.id == category.id
            }
        )

        if let tasks = try? modelContext.fetch(descriptor) {
            for task in tasks {
                task.category = nil
            }
        }

        // Delete category
        modelContext.delete(category)
        categoryToDelete = nil
    }
}

// MARK: - Edit Category View

struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: TaskCategory

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color

    private let availableIcons = [
        "folder", "star", "heart", "bookmark", "tag",
        "briefcase", "house", "person", "cart", "gift",
        "book", "graduationcap", "sportscourt", "gamecontroller",
        "music.note", "camera", "paintbrush", "leaf", "airplane"
    ]

    private let availableColors: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .mint, .teal, .cyan, .indigo
    ]

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(category: TaskCategory) {
        self.category = category
        _name = State(initialValue: category.name)
        _selectedIcon = State(initialValue: category.iconName)
        _selectedColor = State(initialValue: category.color)
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                iconSection
                colorSection
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Form Sections

    private var nameSection: some View {
        Section {
            TextField("Category name", text: $name)
                .font(.headline)
        }
    }

    private var iconSection: some View {
        Section("Icon") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func iconButton(for icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
    }

    private var colorSection: some View {
        Section("Color") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(availableColors, id: \.self) { color in
                    colorButton(for: color)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func colorButton(for color: Color) -> some View {
        Button {
            selectedColor = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay {
                    if selectedColor == color {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func saveCategory() {
        category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        category.iconName = selectedIcon
        category.colorHex = selectedColor.toHex() ?? "#007AFF"

        dismiss()
    }
}

#Preview {
    CategoryManagementView()
        .modelContainer(for: [TaskItem.self, TaskCategory.self], inMemory: true)
}
