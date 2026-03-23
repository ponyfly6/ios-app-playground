import WidgetKit
import Foundation

// MARK: - Timeline Provider

struct TaskMasterTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            tasks: [],
            configuration: WidgetConfiguration(widgetType: .pending)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let tasks = loadTasks(configuration: WidgetConfiguration(widgetType: .pending))
        let entry = SimpleEntry(
            date: Date(),
            tasks: tasks,
            configuration: WidgetConfiguration(widgetType: .pending)
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let configuration = loadConfiguration()

        let tasks = loadTasks(configuration: configuration)
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!

        let entry = SimpleEntry(
            date: currentDate,
            tasks: tasks,
            configuration: configuration
        )

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    // MARK: - Data Loading

    private func loadConfiguration() -> WidgetConfiguration {
        let defaults = UserDefaults(suiteName: "group.com.taskmaster.app")!
        let typeString = defaults.string(forKey: "widgetType") ?? WidgetConfiguration.WidgetType.pending.rawValue
        let widgetType = WidgetConfiguration.WidgetType(rawValue: typeString) ?? .pending
        let categoryID = defaults.string(forKey: "widgetCategoryID")

        return WidgetConfiguration(widgetType: widgetType, categoryID: categoryID)
    }

    private func loadTasks(configuration: WidgetConfiguration) -> [WidgetTask] {
        guard let data = UserDefaults(suiteName: "group.com.taskmaster.app")?.data(forKey: "tasks") else {
            return []
        }

        do {
            let tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
            return filterTasks(tasks, configuration: configuration)
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }

    private func filterTasks(_ tasks: [WidgetTask], configuration: WidgetConfiguration) -> [WidgetTask] {
        var filtered = tasks.filter { !$0.isCompleted }

        switch configuration.widgetType {
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate >= today
            }
        case .pending:
            break
        case .overdue:
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate < Date()
            }
        case .byCategory:
            if let categoryID = configuration.categoryID {
                filtered = filtered.filter { $0.categoryColor != nil }
            }
        }

        return filtered.sorted { task1, task2 in
            task1.priority > task2.priority
        }
    }
}
