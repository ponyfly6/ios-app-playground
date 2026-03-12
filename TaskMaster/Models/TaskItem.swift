import Foundation
import SwiftData
import SwiftUI

@Model
final class TaskItem: Hashable {
    var id: UUID
    var title: String
    var taskDescription: String
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory?
    
    init(
        title: String,
        description: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        category: TaskCategory? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.isCompleted = false
        self.priority = priority
        self.category = category
    }
    
    // MARK: - Hashable
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    nonisolated static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum TaskPriority: Int, Codable, CaseIterable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "flag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
