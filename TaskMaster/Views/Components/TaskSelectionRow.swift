import SwiftUI

// MARK: - Task Selection Row (for batch operations)

struct TaskSelectionRow: View {
    @Environment(\.modelContext) private var modelContext

    let task: TaskItem
    let categories: [TaskCategory]
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isSelected ? .blue : .secondary)

            TaskRowViewContent(task: task, categories: categories)

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    let task = TaskItem(
        title: "Sample task",
        priority: .high
    )
    return TaskSelectionRow(task: task, categories: [], isSelected: false)
        .modelContainer(for: [TaskItem.self, TaskCategory.self, SubTask.self], inMemory: true)
}
