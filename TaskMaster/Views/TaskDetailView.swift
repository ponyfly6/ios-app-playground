import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let task: TaskItem
    let categories: [TaskCategory]
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    @State private var priority: TaskPriority
    @State private var selectedCategory: TaskCategory?
    @State private var isCompleted: Bool
    
    @State private var showingAddCategory = false
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(task: TaskItem, categories: [TaskCategory]) {
        self.task = task
        self.categories = categories
        
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.taskDescription)
        _dueDate = State(initialValue: task.dueDate)
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _priority = State(initialValue: task.priority)
        _selectedCategory = State(initialValue: task.category)
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                completionSection
                titleSection
                descriptionSection
                dueDateSection
                prioritySection
                categorySection
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var completionSection: some View {
        Section {
            Toggle("Completed", isOn: $isCompleted)
        }
    }
    
    private var titleSection: some View {
        Section {
            TextField("Task title", text: $title)
                .font(.headline)
        }
    }
    
    private var descriptionSection: some View {
        Section("Description") {
            TextEditor(text: $description)
                .frame(minHeight: 80)
                .foregroundStyle(description.isEmpty ? .secondary : .primary)
        }
    }
    
    private var dueDateSection: some View {
        Section("Due Date") {
            Toggle("Set due date", isOn: $hasDueDate.animation())
                .onChange(of: hasDueDate) { _, newValue in
                    dueDate = newValue ? Date() : nil
                }
            
            if hasDueDate {
                DatePicker(
                    "Due Date",
                    selection: Binding(
                        get: { dueDate ?? Date() },
                        set: { dueDate = $0 }
                    ),
                    displayedComponents: .date
                )
            }
        }
    }
    
    private var prioritySection: some View {
        Section("Priority") {
            Picker("Priority", selection: $priority) {
                ForEach(TaskPriority.allCases) { priority in
                    Label(priority.displayName, systemImage: priority.icon)
                        .foregroundStyle(priority.color)
                        .tag(priority)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var categorySection: some View {
        Section("Category") {
            if categories.isEmpty {
                emptyCategoryView
            } else {
                categoryPicker
            }
            
            Button {
                showingAddCategory = true
            } label: {
                Label("Add Category", systemImage: "plus.circle")
            }
        }
    }
    
    private var emptyCategoryView: some View {
        Text("No categories yet")
            .foregroundStyle(.secondary)
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            Text("None").tag(nil as TaskCategory?)
            ForEach(categories) { category in
                Label(category.name, systemImage: category.iconName)
                    .tag(category as TaskCategory?)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveTask() {
        task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        task.taskDescription = description
        task.dueDate = dueDate
        task.priority = priority
        task.category = selectedCategory
        task.isCompleted = isCompleted
        task.updatedAt = Date()
        
        dismiss()
    }
}

#Preview {
    let task = TaskItem(
        title: "Buy groceries",
        description: "Milk, eggs, bread",
        priority: .high
    )
    return TaskDetailView(task: task, categories: [])
        .modelContainer(for: TaskItem.self, inMemory: true)
}
