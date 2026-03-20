import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @Query(sort: \TaskCategory.name) private var categories: [TaskCategory]

    @State private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCards
                    priorityDistribution
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                viewModel.updateData(tasks: tasks, categories: categories)
            }
        }
    }

    // MARK: - Overview Cards

    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                totalTasksCard
                completedCard
            }
            HStack(spacing: 12) {
                pendingCard
                overdueCard
            }
        }
    }

    private var totalTasksCard: some View {
        statCard(
            title: "Total",
            value: "\(viewModel.taskStats.total)",
            icon: "list.bullet",
            color: .blue
        )
    }

    private var completedCard: some View {
        VStack(spacing: 8) {
            statCard(
                title: "Completed",
                value: "\(viewModel.taskStats.completed)",
                icon: "checkmark.circle.fill",
                color: .green
            )

            if viewModel.taskStats.total > 0 {
                ProgressView(value: viewModel.taskStats.completionRate)
                    .tint(.green)
                Text(viewModel.taskStats.formattedCompletionRate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pendingCard: some View {
        statCard(
            title: "Pending",
            value: "\(viewModel.taskStats.pending)",
            icon: "clock",
            color: .orange
        )
    }

    private var overdueCard: some View {
        statCard(
            title: "Overdue",
            value: "\(viewModel.taskStats.overdue)",
            icon: "exclamationmark.triangle.fill",
            color: viewModel.taskStats.overdue > 0 ? .red : .gray
        )
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Priority Distribution

    private var priorityDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Distribution")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                ForEach(TaskPriority.allCases) { priority in
                    priorityBar(for: priority)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func priorityBar(for priority: TaskPriority) -> some View {
        let count: Int
        switch priority {
        case .high:
            count = viewModel.taskStats.highPriorityCount
        case .medium:
            count = viewModel.taskStats.mediumPriorityCount
        case .low:
            count = viewModel.taskStats.lowPriorityCount
        }

        let total = viewModel.taskStats.total
        let barHeight = total > 0 ? Double(count) / Double(total) : 0.0
        let maxHeight: Double = 100

        return VStack(spacing: 8) {
            VStack(spacing: 4) {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: maxHeight)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(priority.color)
                        .frame(width: 50, height: maxHeight * barHeight)
                }
                .frame(height: maxHeight)

                Text("\(count)")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }

            Text(priority.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundStyle(.primary)

            if viewModel.categoryStats.isEmpty {
                emptyCategoriesView
            } else {
                ForEach(viewModel.categoryStats) { stats in
                    categoryRow(for: stats)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var emptyCategoriesView: some View {
        Text("No categories created yet")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }

    private func categoryRow(for stats: StatisticsViewModel.CategoryStats) -> some View {
        HStack(spacing: 12) {
            Image(systemName: stats.category.iconName)
                .font(.title3)
                .foregroundStyle(stats.category.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(stats.category.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Text("\(stats.completed) of \(stats.total) completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ProgressView(value: stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0)
                        .tint(stats.category.color)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [TaskItem.self, TaskCategory.self], inMemory: true)
}
