import SwiftUI

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(spacing: 8) {
            iconSection
            Spacer()
            taskCountsSection
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemGroupedBackground)
        }
    }

    private var iconSection: some View {
        HStack {
            Image(systemName: entry.configuration.widgetType.icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(entry.configuration.widgetType.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var taskCountsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(totalTasks)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(totalTasks == 1 ? "Task" : "Tasks")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var totalTasks: Int {
        entry.tasks.count
    }
}

#Preview(as: .systemSmall) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: [],
        configuration: WidgetConfiguration(widgetType: .pending)
    )
}
