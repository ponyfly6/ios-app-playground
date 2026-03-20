import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: options)
        return granted == true
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Scheduling Notifications

    func scheduleNotification(for task: TaskItem, reminderTime: TaskReminderTime) async throws {
        guard let dueDate = task.dueDate else { return }

        // Cancel existing notification for this task
        await cancelNotification(for: task)

        let notificationDate = reminderTime.date(for: dueDate)

        // Only schedule if the reminder time is in the future
        guard notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        // Add category and priority info
        var userInfo: [String: Any] = ["taskId": task.id.uuidString]
        if let category = task.category {
            userInfo["category"] = category.name
        }
        content.userInfo = userInfo

        // Priority badge
        let badgeNumber = task.priority.rawValue + 1
        content.badge = badgeNumber as NSNumber

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: task.notificationIdentifier,
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for task: TaskItem) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.notificationIdentifier])
    }

    func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}

// MARK: - TaskReminderTime

enum TaskReminderTime: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case onDueDate = "On Due Date"
    case oneDayBefore = "1 Day Before"
    case twoDaysBefore = "2 Days Before"
    case oneWeekBefore = "1 Week Before"

    var id: String { rawValue }

    func date(for dueDate: Date) -> Date {
        let calendar = Calendar.current

        switch self {
        case .none:
            return dueDate
        case .onDueDate:
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dueDate) ?? dueDate
        case .oneDayBefore:
            return calendar.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
        case .twoDaysBefore:
            return calendar.date(byAdding: .day, value: -2, to: dueDate) ?? dueDate
        case .oneWeekBefore:
            return calendar.date(byAdding: .day, value: -7, to: dueDate) ?? dueDate
        }
    }

    var displayName: String {
        switch self {
        case .none: return "No Reminder"
        case .onDueDate: return "On Due Date"
        case .oneDayBefore: return "1 Day Before"
        case .twoDaysBefore: return "2 Days Before"
        case .oneWeekBefore: return "1 Week Before"
        }
    }

    var icon: String {
        switch self {
        case .none: return "bell.slash"
        case .onDueDate: return "bell"
        case .oneDayBefore: return "bell.badge"
        case .twoDaysBefore: return "bell.badge.fill"
        case .oneWeekBefore: return "calendar.badge.clock"
        }
    }
}

// MARK: - TaskItem Extension for Notifications

extension TaskItem {
    var notificationIdentifier: String {
        "task-\(id.uuidString)"
    }
}
