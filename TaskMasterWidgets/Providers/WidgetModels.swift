import SwiftUI

// MARK: - Widget Task Model

struct WidgetTask: Identifiable, Codable {
    let id: String
    let title: String
    let priority: String
    let priorityColor: String
    let isCompleted: Bool
    let dueDate: Date?
    let categoryName: String?
    let categoryColor: String?
}

// MARK: - Widget Configuration

struct WidgetConfiguration: Codable {
    enum WidgetType: String, Codable, CaseIterable, Identifiable {
        case today = "Today"
        case pending = "Pending"
        case overdue = "Overdue"
        case byCategory = "By Category"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .today: return "calendar"
            case .pending: return "list.bullet"
            case .overdue: return "exclamationmark.triangle"
            case .byCategory: return "folder"
            }
        }
    }

    var widgetType: WidgetType
    var categoryID: String?
}
