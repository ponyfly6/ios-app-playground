import SwiftUI
import SwiftData

struct BatchOperationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedTasks: Set<TaskItem>
    let categories: [TaskCategory]

    @State private var showingDeleteConfirmation = false
    @State private var showingCategoryPicker = false
    @State private var selectedCategory: TaskCategory?
    @State private var showingPriorityPicker = false
    @State private var selectedPriority: TaskPriority?
    @State private var showingReminderAlert = false

    var body: some View {
        NavigationStack {
            Form {
                infoSection
                actionsSection
            }
            .navigationTitle("Batch Operations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Tasks", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteSelectedTasks()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedTasks.count) task(s)?")
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    selectedCategory: $selectedCategory,
                    categories: categories
                ) { category in
                    changeCategory(for: category)
                    showingCategoryPicker = false
                }
            }
            .sheet(isPresented: $showingPriorityPicker) {
                priorityPickerSheet
            }
            .alert("Complete All Subtasks", isPresented: $showingReminderAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Complete") {
                    completeAllSubtasks()
                }
            } message: {
                Text("Mark all subtasks in selected tasks as completed?")
            }
        }
    }

    // MARK: - Sections

    private var infoSection: some View {
        Section {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(selectedTasks.count) Task(s) Selected")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Tap actions below to apply to all selected tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var actionsSection: some View {
        Section("Actions") {
            completeAction
            uncompleteAction
            moveToCategoryAction
            changePriorityAction
            completeSubtasksAction
            deleteAction
        }
    }

    // MARK: - Actions

    private var completeAction: some View {
        Button {
            withAnimation {
                for task in selectedTasks {
                    task.isCompleted = true
                    task.updatedAt = Date()
                }
                dismiss()
            }
        } label: {
            Label("Mark as Completed", systemImage: "checkmark.circle")
        }
        .disabled(selectedTasks.isEmpty)
    }

    private var uncompleteAction: some View {
        Button {
            withAnimation {
                for task in selectedTasks {
                    task.isCompleted = false
                    task.updatedAt = Date()
                }
                dismiss()
            }
        } label: {
            Label("Mark as Uncompleted", systemImage: "xmark.circle")
        }
        .disabled(selectedTasks.isEmpty)
    }

    private var moveToCategoryAction: some View {
        Button {
            showingCategoryPicker = true
            selectedCategory = nil
        } label: {
            Label("Move to Category", systemImage: "folder")
        }
        .disabled(selectedTasks.isEmpty || categories.isEmpty)
    }

    private var changePriorityAction: some View {
        Button {
            showingPriorityPicker = true
            selectedPriority = nil
        } label: {
            Label("Change Priority", systemImage: "flag")
        }
        .disabled(selectedTasks.isEmpty)
    }

    private var completeSubtasksAction: some View {
        Button {
            showingReminderAlert = true
        } label: {
            Label("Complete All Subtasks", systemImage: "checklist.checked")
        }
        .disabled(selectedTasks.isEmpty || !selectedTasksContainsSubtasks)
    }

    private var deleteAction: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .disabled(selectedTasks.isEmpty)
    }

    // MARK: - Priority Picker

    private var priorityPickerSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Select Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Label(priority.displayName, systemImage: priority.icon)
                                .foregroundStyle(priority.color)
                                .tag(priority as TaskPriority?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Change Priority")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingPriorityPicker = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        if let priority = selectedPriority {
                            changePriority(to: priority)
                        }
                        showingPriorityPicker = false
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedPriority == nil)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private var selectedTasksContainsSubtasks: Bool {
        selectedTasks.contains { !$0.subTasks.isEmpty }
    }

    private func deleteSelectedTasks() {
        for task in selectedTasks {
            modelContext.delete(task)
        }
        selectedTasks.removeAll()
        dismiss()
    }

    private func changeCategory(for category: TaskCategory?) {
        for task in selectedTasks {
            task.category = category
            task.updatedAt = Date()
        }
        selectedTasks.removeAll()
        dismiss()
    }

    private func changePriority(to priority: TaskPriority) {
        for task in selectedTasks {
            task.priority = priority
            task.updatedAt = Date()
        }
        selectedTasks.removeAll()
        dismiss()
    }

    private func completeAllSubtasks() {
        for task in selectedTasks {
            for subTask in task.subTasks {
                subTask.isCompleted = true
            }
        }
        selectedTasks.removeAll()
        dismiss()
    }
}

#Preview {
    BatchOperationsView(
        selectedTasks: .constant([]),
        categories: []
    )
    .modelContainer(for: [TaskItem.self, TaskCategory.self, SubTask.self], inMemory: true)
}
