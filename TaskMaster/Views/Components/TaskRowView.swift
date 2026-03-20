import SwiftUI

// MARK: - Task Row View

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext

    let task: TaskItem
    let categories: [TaskCategory]

    @State private var showingCategoryPicker = false
    @State private var selectedCategoryForMove: TaskCategory?

    var body: some View {
        TaskRowViewContent(task: task, categories: categories)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .contextMenu {
                contextMenuContent
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    selectedCategory: $selectedCategoryForMove,
                    categories: categories
                ) { newCategory in
                    task.category = newCategory
                    task.updatedAt = Date()
                }
            }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            duplicateTask()
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        Button {
            showingCategoryPicker = true
            selectedCategoryForMove = task.category
        } label: {
            Label("Move to Category", systemImage: "folder")
        }

        if !task.subTasks.isEmpty {
            Button {
                completeAllSubtasks()
            } label: {
                Label("Complete All Subtasks", systemImage: "checklist.checked")
            }
        }

        Button {
            copyTaskTitle()
        } label: {
            Label("Copy Title", systemImage: "doc.on.clipboard")
        }

        Divider()

        Button(role: .destructive) {
            task.isCompleted = true
            task.updatedAt = Date()
        } label: {
            Label("Mark Completed", systemImage: "checkmark.circle")
        }
    }

    // MARK: - Context Menu Actions

    private func duplicateTask() {
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

    private func copyTaskTitle() {
        #if os(iOS)
        UIPasteboard.general.string = task.title
        #endif
    }

    private func completeAllSubtasks() {
        for subTask in task.subTasks {
            subTask.isCompleted = true
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: TaskItem(
                title: "Buy groceries",
                description: "Milk, eggs, bread",
                priority: .high
            ),
            categories: []
        )
        TaskRowView(
            task: TaskItem(
                title: "Read book",
                priority: .low
            ),
            categories: []
        )
        TaskRowView(
            task: {
                let task = TaskItem(title: "Completed task")
                task.isCompleted = true
                return task
            }(),
            categories: []
        )
    }
    .modelContainer(for: [TaskItem.self, TaskCategory.self, SubTask.self], inMemory: true)
}
