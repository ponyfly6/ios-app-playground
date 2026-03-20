import SwiftUI
import SwiftData

struct SubTaskListView: View {
    @Environment(\.modelContext) private var modelContext

    let task: TaskItem

    @State private var showingAddSubTask = false
    @State private var newSubTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with progress
            HStack {
                Text("Subtasks")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if !task.subTasks.isEmpty {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if totalCount > 0 {
                        ProgressView(value: completionRate)
                            .frame(width: 60)
                    }
                }
            }

            if task.subTasks.isEmpty {
                emptyStateView
            } else {
                subTasksList
            }

            addSubTaskButton
        }
        .sheet(isPresented: $showingAddSubTask) {
            addSubTaskSheet
        }
    }

    // MARK: - Computed Properties

    private var totalCount: Int {
        task.subTasks.count
    }

    private var completedCount: Int {
        task.subTasks.filter { $0.isCompleted }.count
    }

    private var completionRate: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
    }

    // MARK: - Views

    private var emptyStateView: some View {
        Text("No subtasks yet")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }

    private var subTasksList: some View {
        VStack(spacing: 0) {
            ForEach(task.subTasks) { subTask in
                subTaskRow(subTask)

                if subTask.id != task.subTasks.last?.id {
                    Divider()
                        .padding(.leading, 44)
                }
            }
        }
    }

    private func subTaskRow(_ subTask: SubTask) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    subTask.isCompleted.toggle()
                }
            } label: {
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(subTask.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(subTask.title)
                .font(.subheadline)
                .strikethrough(subTask.isCompleted)
                .foregroundStyle(subTask.isCompleted ? .secondary : .primary)

            Spacer()

            Button {
                withAnimation {
                    modelContext.delete(subTask)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private var addSubTaskButton: some View {
        Button {
            showingAddSubTask = true
            newSubTaskTitle = ""
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Add Subtask")
            }
            .font(.subheadline)
            .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Subtask Sheet

    private var addSubTaskSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Subtask title", text: $newSubTaskTitle)
                        .autocapitalization(.sentences)
                }
            }
            .navigationTitle("New Subtask")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingAddSubTask = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addSubTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func addSubTask() {
        let subTask = SubTask(
            title: newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            parentTask: task
        )

        modelContext.insert(subTask)
        showingAddSubTask = false
    }
}

#Preview {
    let task = TaskItem(
        title: "Project deliverables",
        description: "Complete all project milestones",
        priority: .high
    )

    return SubTaskListView(task: task)
        .modelContainer(for: [TaskItem.self, SubTask.self], inMemory: true)
}
