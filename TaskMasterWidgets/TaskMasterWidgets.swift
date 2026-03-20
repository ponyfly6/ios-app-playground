import WidgetKit
import SwiftUI

// MARK: - Main Widget

@main
struct TaskMasterWidget: Widget {
    let kind: String = "TaskMasterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskMasterTimelineProvider()) { entry in
            Group {
                if #available(iOS 18.0, *) {
                    TaskMasterWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    TaskMasterWidgetEntryView(entry: entry)
                        .padding()
                        .background()
                }
            }
        }
        .configurationDisplayName("TaskMaster")
        .description("See your tasks at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Entry View

struct TaskMasterWidgetEntryView: View {
    var entry: SimpleEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard let hexCode = Int(hexSanitized, radix: 16) else { return nil }

        let red = Double((hexCode >> 16) & 0xFF) / 255
        let green = Double((hexCode >> 8) & 0xFF) / 255
        let blue = Double(hexCode & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}

#Preview("Small", as: .systemSmall) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: mockTasks,
        configuration: WidgetConfiguration(widgetType: .pending)
    )
}

#Preview("Medium", as: .systemMedium) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: mockTasks,
        configuration: WidgetConfiguration(widgetType: .today)
    )
}

#Preview("Large", as: .systemLarge) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: mockTasks,
        configuration: WidgetConfiguration(widgetType: .overdue)
    )
}

// MARK: - Mock Data

private let mockTasks: [WidgetTask] = [
    WidgetTask(from: {
        let task = TaskItem(title: "Buy groceries", priority: .high)
        return task
    }()),
    WidgetTask(from: {
        let task = TaskItem(title: "Complete project report", priority: .high)
        return task
    }()),
    WidgetTask(from: {
        let task = TaskItem(title: "Call client", priority: .medium)
        return task
    }()),
    WidgetTask(from: {
        let task = TaskItem(title: "Review documentation", priority: .medium)
        return task
    }()),
    WidgetTask(from: {
        let task = TaskItem(title: "Update README", priority: .low)
        return task
    }()),
    WidgetTask(from: {
        let task = TaskItem(title: "Clean workspace", priority: .low)
        return task
    }())
]
