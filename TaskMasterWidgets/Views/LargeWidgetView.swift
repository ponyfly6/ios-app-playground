import SwiftUI

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            tasksList
        }
        .containerBackground(for: .widget) {
            Color(.systemGroupedBackground)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: entry.configuration.widgetType.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text(entry.configuration.widgetType.rawValue)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if !entry.tasks.isEmpty {
                    HStack(spacing: 4) {
                        Text("\(completionPercentage)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)

                        ProgressView(value: Double(completionPercentage) / 100.0)
                            .frame(width: 60)
                            .tint(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            // Priority breakdown
            if !entry.tasks.isEmpty {
                HStack(spacing: 8) {
                    priorityBadge(priority: .high, count: highPriorityCount)
                    priorityBadge(priority: .medium, count: mediumPriorityCount)
                    priorityBadge(priority: .low, count: lowPriorityCount)
                }
            }
        }
        .padding()
    }

    private var tasksList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entry.tasks.isEmpty {
                emptyState
            } else {
                ForEach(Array(entry.tasks.prefix(6).enumerated()), id: \.element.id) { index, task in
                    taskRow(task)
                    if index < min(entry.tasks.count, 6) - 1 {
                        Divider()
                            .padding(.leading, 48)
                    }
                }

                if entry.tasks.count > 6 {
                    Divider()
                        .padding(.leading, 48)

                    Text("+\(entry.tasks.count - 6) more tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 16)
                        .padding(.vertical, 8)
                }
            }
        }
    }

    private func taskRow(_ task: WidgetTask) -> some View {
        HStack(spacing: 12) {
            // Priority indicator
            priorityIndicator(task)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    if let categoryName = task.categoryName, let categoryColor = task.categoryColor {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: categoryColor) ?? .blue)
                                .frame(width: 6, height: 6)

                            Text(categoryName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)

                            Text(dueText(dueDate))
                                .font(.caption2)
                        }
                        .foregroundStyle(isOverdue(dueDate) ? .red : .secondary)
                    }
                }
            }

            Spacer()

            // Subtask count
            // Note: WidgetTask doesn't have subtask count, would need to extend model
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func priorityIndicator(_ task: WidgetTask) -> some View {
        Image(systemName: task.priority == "2" ? "flag.fill" : "flag")
            .font(.callout)
            .foregroundStyle(colorFromHex(task.priorityColor))
            .frame(width: 20)
    }

    private func priorityBadge(priority: TaskPriority, count: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: priority.icon)
                .font(.caption)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.1))
        .foregroundStyle(priority.color)
        .clipShape(Capsule())
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No tasks yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Tap + to add your first task")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Helpers

    private var highPriorityCount: Int {
        entry.tasks.filter { $0.priority == "2" }.count
    }

    private var mediumPriorityCount: Int {
        entry.tasks.filter { $0.priority == "1" }.count
    }

    private var lowPriorityCount: Int {
        entry.tasks.filter { $0.priority == "0" }.count
    }

    private var completionPercentage: Int {
        guard !entry.tasks.isEmpty else { return 0 }
        // This would calculate based on completed vs total
        return 0 // Placeholder
    }

    private func dueText(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func isOverdue(_ date: Date) -> Bool {
        date < Date()
    }

    private func colorFromHex(_ hex: String) -> Color {
        Color(hex: hex) ?? .blue
    }
}

#Preview(as: .systemLarge) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: [],
        configuration: WidgetConfiguration(widgetType: .pending)
    )
}
