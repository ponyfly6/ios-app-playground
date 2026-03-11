import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TaskListViewModel
    let categories: [TaskCategory]
    
    var body: some View {
        NavigationStack {
            Form {
                sortSection
                filterSection
                displaySection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var sortSection: some View {
        Section("Sort By") {
            Picker("Sort", selection: $viewModel.sortBy) {
                ForEach(TaskSortOption.allCases) { option in
                    Label(option.rawValue, systemImage: option.icon)
                        .tag(option)
                }
            }
            
            Toggle("Ascending", isOn: $viewModel.sortAscending)
        }
    }
    
    private var filterSection: some View {
        Section {
            if !categories.isEmpty {
                categoryFilter
            }
            
            priorityFilter
            
            if viewModel.hasActiveFilters {
                clearFiltersButton
            }
        } header: {
            Text("Filters")
        } footer: {
            if viewModel.hasActiveFilters {
                Text("Filters are applied to the task list")
            }
        }
    }
    
    private var categoryFilter: some View {
        Picker("Category", selection: $viewModel.selectedCategory) {
            Text("All Categories").tag(nil as TaskCategory?)
            ForEach(categories) { category in
                Label(category.name, systemImage: category.iconName)
                    .tag(category as TaskCategory?)
            }
        }
    }
    
    private var priorityFilter: some View {
        Picker("Priority", selection: $viewModel.selectedPriority) {
            Text("All Priorities").tag(nil as TaskPriority?)
            ForEach(TaskPriority.allCases) { priority in
                Label(priority.displayName, systemImage: priority.icon)
                    .tag(priority as TaskPriority?)
            }
        }
    }
    
    private var clearFiltersButton: some View {
        Button(role: .destructive) {
            viewModel.clearFilters()
        } label: {
            Label("Clear All Filters", systemImage: "xmark.circle")
        }
    }
    
    private var displaySection: some View {
        Section("Display") {
            Toggle("Show Completed Tasks", isOn: $viewModel.showingCompleted)
        }
    }
}

#Preview {
    SettingsView(
        viewModel: TaskListViewModel(),
        categories: []
    )
}
