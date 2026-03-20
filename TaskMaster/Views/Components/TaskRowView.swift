import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    
    var body: some View {
        HStack(spacing: 12) {
            completionIndicator
            taskContent
            Spacer()
            priorityBadge
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    // MARK: - View Components
    
    private var completionIndicator: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                task.isCompleted.toggle()
                task.updatedAt = Date()
            }
        } label: {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(task.isCompleted ? .green : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    private var taskContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleView
            metadataView
        }
    }
    
    private var titleView: some View {
        Text(task.title)
            .font(.headline)
            .foregroundStyle(task.isCompleted ? .secondary : .primary)
            .strikethrough(task.isCompleted)
            .lineLimit(2)
    }
    
    private var metadataView: some View {
        HStack(spacing: 8) {
            if !task.subTasks.isEmpty {
                subTasksProgressBadge
            }

            if let dueDate = task.dueDate {
                dueDateBadge(dueDate)
            }

            if let category = task.category {
                categoryBadge(category)
            }
        }
        .font(.caption)
    }
    
    private func dueDateBadge(_ date: Date) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
            Text(date.formatted(date: .abbreviated, time: .omitted))
        }
        .foregroundStyle(isOverdue(date) ? .red : .secondary)
    }
    
    private func categoryBadge(_ category: TaskCategory) -> some View {
        HStack(spacing: 2) {
            Image(systemName: category.iconName)
            Text(category.name)
        }
        .foregroundStyle(category.color)
    }
    
    private var priorityBadge: some View {
        Image(systemName: task.priority.icon)
            .foregroundStyle(task.priority.color)
            .font(.title3)
    }
    
    // MARK: - Helpers

    private func isOverdue(_ date: Date) -> Bool {
        !task.isCompleted && date < Date()
    }

    private var subTasksCompletedCount: Int {
        task.subTasks.filter { $0.isCompleted }.count
    }

    private var subTasksTotalCount: Int {
        task.subTasks.count
    }

    private var subTasksProgressBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: subTasksCompletedCount == subTasksTotalCount ? "checklist.checked" : "checklist")
            Text("\(subTasksCompletedCount)/\(subTasksTotalCount)")
        }
        .foregroundStyle(subTasksCompletedCount == subTasksTotalCount ? .green : .secondary)
    }
}

#Preview {
    List {
        TaskRowView(task: TaskItem(
            title: "Buy groceries",
            description: "Milk, eggs, bread",
            priority: .high
        ))
        TaskRowView(task: TaskItem(
            title: "Read book",
            priority: .low
        ))
        TaskRowView(task: {
            let task = TaskItem(title: "Completed task")
            task.isCompleted = true
            return task
        }())
    }
    .modelContainer(for: TaskItem.self, inMemory: true)
}
