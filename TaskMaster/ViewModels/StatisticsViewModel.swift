import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class StatisticsViewModel {
    struct TaskStats {
        let total: Int
        let completed: Int
        let pending: Int
        let overdue: Int
        let highPriorityCount: Int
        let mediumPriorityCount: Int
        let lowPriorityCount: Int
        let completionRate: Double

        var formattedCompletionRate: String {
            String(format: "%.0f%%", completionRate * 100)
        }
    }

    struct CategoryStats {
        let category: TaskCategory
        let total: Int
        let completed: Int
    }

    var tasks: [TaskItem] = []
    var categories: [TaskCategory] = []

    var taskStats: TaskStats {
        let total = tasks.count
        let completed = tasks.filter { $0.isCompleted }.count
        let pending = total - completed
        let overdue = tasks.filter { task in
            !task.isCompleted,
            let dueDate = task.dueDate,
            dueDate < Date()
        }.count
        let highPriorityCount = tasks.filter { $0.priority == .high }.count
        let mediumPriorityCount = tasks.filter { $0.priority == .medium }.count
        let lowPriorityCount = tasks.filter { $0.priority == .low }.count
        let completionRate = total > 0 ? Double(completed) / Double(total) : 0.0

        return TaskStats(
            total: total,
            completed: completed,
            pending: pending,
            overdue: overdue,
            highPriorityCount: highPriorityCount,
            mediumPriorityCount: mediumPriorityCount,
            lowPriorityCount: lowPriorityCount,
            completionRate: completionRate
        )
    }

    var categoryStats: [CategoryStats] {
        categories.map { category in
            let categoryTasks = tasks.filter { $0.category?.id == category.id }
            let total = categoryTasks.count
            let completed = categoryTasks.filter { $0.isCompleted }.count

            return CategoryStats(
                category: category,
                total: total,
                completed: completed
            )
        }.sorted { $0.total > $1.total }
    }

    func updateData(tasks: [TaskItem], categories: [TaskCategory]) {
        self.tasks = tasks
        self.categories = categories
    }
}
