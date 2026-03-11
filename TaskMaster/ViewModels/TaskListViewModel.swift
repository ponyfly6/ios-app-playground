import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class TaskListViewModel {
    var searchText: String = ""
    var selectedPriority: TaskPriority?
    var selectedCategory: TaskCategory?
    var sortBy: TaskSortOption = .createdAt
    var sortAscending: Bool = false
    var showingCompleted: Bool = true
    
    func filterTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        var filtered = tasks
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Priority filter
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category?.id == category.id }
        }
        
        // Completed filter
        if !showingCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Sort
        filtered = sortTasks(filtered)
        
        return filtered
    }
    
    private func sortTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        let sorted: [TaskItem]
        switch sortBy {
        case .createdAt:
            sorted = tasks.sorted { $0.createdAt < $1.createdAt }
        case .dueDate:
            sorted = tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            sorted = tasks.sorted { $0.priority.rawValue > $1.priority.rawValue }
        case .title:
            sorted = tasks.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
        
        return sortAscending ? sorted.reversed() : sorted
    }
    
    func clearFilters() {
        searchText = ""
        selectedPriority = nil
        selectedCategory = nil
    }
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedPriority != nil || selectedCategory != nil
    }
}

enum TaskSortOption: String, CaseIterable, Identifiable {
    case createdAt = "Created"
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .createdAt: return "calendar.badge.plus"
        case .dueDate: return "calendar"
        case .priority: return "flag"
        case .title: return "textformat"
        }
    }
}
