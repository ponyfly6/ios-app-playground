import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let categories: [TaskCategory]
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var priority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory?
    @State private var reminderEnabled = false
    @State private var reminderTime: TaskReminderTime = .onDueDate

    @State private var showingAddCategory = false
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                descriptionSection
                dueDateSection
                prioritySection
                categorySection
                reminderSection
            }
            .navigationTitle("New Task")
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

    private var reminderSection: some View {
        Section("Reminder") {
            if hasDueDate {
                Toggle("Enable Reminder", isOn: $reminderEnabled.animation())

                if reminderEnabled {
                    Picker("Remind Me", selection: $reminderTime) {
                        ForEach(TaskReminderTime.allCases) { option in
                            if option != .none {
                                Label(option.displayName, systemImage: option.icon)
                                    .tag(option)
                            }
                        }
                    }
                }
            } else {
                Text("Set a due date first to enable reminders")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions
    
    private func saveTask() {
        let task = TaskItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description,
            dueDate: dueDate,
            priority: priority,
            category: selectedCategory,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil
        )

        modelContext.insert(task)

        // Schedule notification if reminder is enabled
        Task {
            if reminderEnabled, reminderTime != nil {
                try? await NotificationManager.shared.scheduleNotification(for: task, reminderTime: reminderTime)
            }
        }

        dismiss()
    }
}

#Preview {
    AddTaskView(categories: [])
        .modelContainer(for: TaskItem.self, inMemory: true)
}
