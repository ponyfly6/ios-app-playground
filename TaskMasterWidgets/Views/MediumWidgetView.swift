import SwiftUI

// MARK: - Medium Widget View

struct MediumWidgetView: View {
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
        HStack {
            Image(systemName: entry.configuration.widgetType.icon)
                .font(.title3)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.configuration.widgetType.rawValue)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(entry.tasks.count) task\(entry.tasks.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !entry.tasks.isEmpty {
                Text("\(completionPercentage)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private var tasksList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entry.tasks.isEmpty {
                emptyState
            } else {
                ForEach(Array(entry.tasks.prefix(4).enumerated()), id: \.element.id) { index, task in
                    taskRow(task)
                    if index < min(entry.tasks.count, 4) - 1 {
                        Divider()
                            .padding(.leading, 48)
                    }
                }

                if entry.tasks.count > 4 {
                    Divider()
                        .padding(.leading, 48)

                    Text("+\(entry.tasks.count - 4) more")
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
            priorityIndicator(task)

            Text(task.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.primary)

            Spacer()

            if let dueDate = task.dueDate {
                Text(dueText(dueDate))
                    .font(.caption2)
                    .foregroundStyle(isOverdue(dueDate) ? .red : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func priorityIndicator(_ task: WidgetTask) -> some View {
        Image(systemName: task.priority == "2" ? "flag.fill" : "flag")
            .font(.caption)
            .foregroundStyle(colorFromHex(task.priorityColor))
            .frame(width: 12)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checklist")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No tasks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers

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

#Preview(as: .systemMedium) {
    TaskMasterWidget()
} timeline: {
    SimpleEntry(
        date: Date(),
        tasks: [],
        configuration: WidgetConfiguration(widgetType: .pending)
    )
}
