import SwiftUI
import SwiftData

@main
struct TaskMasterApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
        .modelContainer(for: [TaskItem.self, TaskCategory.self])
    }
}
