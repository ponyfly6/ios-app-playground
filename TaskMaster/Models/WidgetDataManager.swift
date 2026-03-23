import Foundation
import SwiftData
import WidgetKit

// MARK: - Widget Data Manager

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let sharedDefaults = UserDefaults(suiteName: "group.com.taskmaster.app")

    private init() {}

    // MARK: - Update Widget Data

    func updateWidgetData(tasks: [TaskItem]) {
        let widgetTasks = tasks.map { WidgetTask(from: $0) }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(widgetTasks)

            sharedDefaults?.set(data, forKey: "tasks")

            // Notify widget to refresh
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            print("Error encoding widget tasks: \(error)")
        }
    }

    // MARK: - Widget Configuration

    func saveWidgetConfiguration(type: WidgetConfiguration.WidgetType, categoryID: String? = nil) {
        sharedDefaults?.set(type.rawValue, forKey: "widgetType")
        sharedDefaults?.set(categoryID, forKey: "widgetCategoryID")

        // Reload widget to apply new configuration
        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadWidgetConfiguration() -> WidgetConfiguration? {
        guard let typeString = sharedDefaults?.string(forKey: "widgetType"),
              let widgetType = WidgetConfiguration.WidgetType(rawValue: typeString) else {
            return nil
        }

        let categoryID = sharedDefaults?.string(forKey: "widgetCategoryID")

        return WidgetConfiguration(widgetType: widgetType, categoryID: categoryID)
    }

    // MARK: - Category List for Widget

    func saveCategories(_ categories: [TaskCategory]) {
        let categoryData = categories.map { ["id": $0.id.uuidString, "name": $0.name, "icon": $0.iconName, "color": $0.colorHex] }

        do {
            let data = try JSONSerialization.data(withJSONObject: categoryData)
            sharedDefaults?.set(data, forKey: "categories")
        } catch {
            print("Error saving categories: \(error)")
        }
    }
}
