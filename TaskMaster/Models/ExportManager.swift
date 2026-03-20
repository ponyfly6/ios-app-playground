import Foundation
import SwiftData

enum ExportFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case csv = "CSV"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }

    var mimeType: String {
        switch self {
        case .json: return "application/json"
        case .csv: return "text/csv"
        }
    }
}

@MainActor
final class ExportManager {
    static let shared = ExportManager()

    private init() {}

    // MARK: - Data Models

    struct ExportData: Codable {
        let tasks: [ExportedTask]
        let categories: [ExportedCategory]
        let exportedAt: Date
    }

    struct ExportedTask: Codable {
        let id: String
        let title: String
        let description: String
        let createdAt: Date
        let updatedAt: Date
        let dueDate: Date?
        let isCompleted: Bool
        let priority: String
        let categoryId: String?
        let categoryName: String?
        let reminderEnabled: Bool
        let reminderTime: String?
        let subTasks: [ExportedSubTask]

        init(from task: TaskItem) {
            self.id = task.id.uuidString
            self.title = task.title
            self.description = task.taskDescription
            self.createdAt = task.createdAt
            self.updatedAt = task.updatedAt
            self.dueDate = task.dueDate
            self.isCompleted = task.isCompleted
            self.priority = task.priority.displayName
            self.categoryId = task.category?.id.uuidString
            self.categoryName = task.category?.name
            self.reminderEnabled = task.reminderEnabled
            self.reminderTime = task.reminderTime?.displayName
            self.subTasks = task.subTasks.map { ExportedSubTask(from: $0) }
        }
    }

    struct ExportedSubTask: Codable {
        let id: String
        let title: String
        let isCompleted: Bool
        let createdAt: Date

        init(from subTask: SubTask) {
            self.id = subTask.id.uuidString
            self.title = subTask.title
            self.isCompleted = subTask.isCompleted
            self.createdAt = subTask.createdAt
        }
    }

    struct ExportedCategory: Codable {
        let id: String
        let name: String
        let iconName: String
        let colorHex: String

        init(from category: TaskCategory) {
            self.id = category.id.uuidString
            self.name = category.name
            self.iconName = category.iconName
            self.colorHex = category.colorHex
        }
    }

    // MARK: - Export Methods

    func exportToJSON(tasks: [TaskItem], categories: [TaskCategory]) throws -> Data {
        let exportData = ExportData(
            tasks: tasks.map { ExportedTask(from: $0) },
            categories: categories.map { ExportedCategory(from: $0) },
            exportedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        return try encoder.encode(exportData)
    }

    func exportToCSV(tasks: [TaskItem], categories: [TaskCategory]) throws -> Data {
        var csvContent = "Title,Description,Created At,Updated At,Due Date,Completed,Priority,Category,Reminder Enabled,Reminder Time,Subtasks Count,Subtasks Completed\n"

        let dateFormatter = ISO8601DateFormatter()

        for task in tasks {
            let subTasksTotal = task.subTasks.count
            let subTasksCompleted = task.subTasks.filter { $0.isCompleted }.count

            var line = ""
            line += escapeCSV(task.title)
            line += "," + escapeCSV(task.taskDescription)
            line += "," + dateFormatter.string(from: task.createdAt)
            line += "," + dateFormatter.string(from: task.updatedAt)
            line += "," + (task.dueDate.map { dateFormatter.string(from: $0) } ?? "")
            line += "," + (task.isCompleted ? "Yes" : "No")
            line += "," + task.priority.displayName
            line += "," + escapeCSV(task.category?.name ?? "")
            line += "," + (task.reminderEnabled ? "Yes" : "No")
            line += "," + (task.reminderTime?.displayName ?? "")
            line += "," + String(subTasksTotal)
            line += "," + String(subTasksCompleted)

            csvContent += line + "\n"
        }

        return csvContent.data(using: .utf8) ?? Data()
    }

    // MARK: - Helpers

    private func escapeCSV(_ string: String) -> String {
        let needsEscaping = string.contains(",") || string.contains("\"") || string.contains("\n")

        if needsEscaping {
            let escaped = string.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }

        return string
    }

    func generateFilename(for format: ExportFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        return "taskmaster_\(timestamp).\(format.fileExtension)"
    }
}
