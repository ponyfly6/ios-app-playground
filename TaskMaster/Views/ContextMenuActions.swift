import SwiftUI
import SwiftData

// MARK: - Context Menu Actions

struct ContextMenuActions {
    @Environment(\.modelContext) private var modelContext

    let task: TaskItem
    let categories: [TaskCategory]

    @State private var showingCategoryPicker = false
    @State private var selectedCategory: TaskCategory?
    @State private var showingCopyAlert = false

    func duplicateTask() {
        let newTask = TaskItem(
            title: "\(task.title) (copy)",
            description: task.taskDescription,
            dueDate: task.dueDate,
            priority: task.priority,
            category: task.category,
            reminderEnabled: task.reminderEnabled,
            reminderTime: task.reminderTime
        )

        // Copy subtasks
        for subTask in task.subTasks {
            let newSubTask = SubTask(
                title: subTask.title,
                parentTask: newTask
            )
            newSubTask.isCompleted = subTask.isCompleted
            modelContext.insert(newSubTask)
        }

        modelContext.insert(newTask)
    }

    func moveTask(to category: TaskCategory?) {
        task.category = category
        task.updatedAt = Date()
    }

    func copyTaskTitle() {
        #if os(iOS)
        UIPasteboard.general.string = task.title
        #endif
    }

    func completeAllSubtasks() {
        for subTask in task.subTasks {
            subTask.isCompleted = true
        }
    }
}

// MARK: - Category Picker View

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: TaskCategory?
    let categories: [TaskCategory]
    let onConfirm: (TaskCategory?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Select Category", selection: $selectedCategory) {
                        Text("None").tag(nil as TaskCategory?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.iconName)
                                .tag(category as TaskCategory?)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Move to Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Move") {
                        onConfirm(selectedCategory)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
