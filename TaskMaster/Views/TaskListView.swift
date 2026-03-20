import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    @Query(sort: \TaskCategory.name) private var categories: [TaskCategory]
    
    @State private var viewModel = TaskListViewModel()
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var showingStatistics = false
    
    private var filteredTasks: [TaskItem] {
        viewModel.filterTasks(allTasks)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                
                if allTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        statisticsButton
                        settingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    addTaskButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(categories: categories)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel, categories: categories)
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundView: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Tasks Yet")
                .font(.title2.bold())
            
            Text("Tap the + button to add your first task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var taskListView: some View {
        List {
            if viewModel.hasActiveFilters && filteredTasks.isEmpty {
                noResultsView
            } else {
                ForEach(filteredTasks) { task in
                    NavigationLink(value: task) {
                        TaskRowView(task: task)
                    }
                    .swipeActions(edge: .trailing) {
                        deleteButton(for: task)
                    }
                    .swipeActions(edge: .leading) {
                        completeButton(for: task)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: TaskItem.self) { task in
            TaskDetailView(task: task, categories: categories)
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No tasks match your filters")
                .font(.headline)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Toolbar Buttons

    private var statisticsButton: some View {
        Button {
            showingStatistics = true
        } label: {
            Image(systemName: "chart.bar.fill")
        }
    }

    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
    }
    
    private var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
        }
    }
    
    // MARK: - Swipe Actions
    
    private func deleteButton(for task: TaskItem) -> some View {
        Button(role: .destructive) {
            withAnimation {
                modelContext.delete(task)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func completeButton(for task: TaskItem) -> some View {
        Button {
            withAnimation {
                task.isCompleted.toggle()
                task.updatedAt = Date()
            }
        } label: {
            Label(
                task.isCompleted ? "Uncomplete" : "Complete",
                systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle"
            )
        }
        .tint(task.isCompleted ? .orange : .green)
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: [TaskItem.self, TaskCategory.self], inMemory: true)
}
