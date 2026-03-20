import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var pendingNotificationCount = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                authorizationSection
                pendingNotificationsSection
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                Task {
                    await loadNotificationSettings()
                }
            }
            .alert("Notification", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Sections

    private var authorizationSection: some View {
        Section("Authorization") {
            HStack {
                Image(systemName: authorizationIcon)
                    .foregroundStyle(authorizationColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text(authorizationStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                switch authorizationStatus {
                case .notDetermined:
                    Button("Request") {
                        Task {
                            await requestAuthorization()
                        }
                    }
                    .buttonStyle(.bordered)
                case .denied:
                    Button("Settings") {
                        alertMessage = "To enable notifications, go to Settings > TaskMaster > Notifications"
                        showingAlert = true
                    }
                    .buttonStyle(.bordered)
                default:
                    EmptyView()
                }
            }
        }
    }

    private var pendingNotificationsSection: some View {
        Section("Scheduled Reminders") {
            HStack {
                Image(systemName: "bell.badge")
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pending Notifications")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text("\(pendingNotificationCount) reminder(s) scheduled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if pendingNotificationCount > 0 {
                    Button("Clear All") {
                        Task {
                            await clearAllNotifications()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    // MARK: - Helpers

    private var authorizationIcon: String {
        switch authorizationStatus {
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle"
        case .provisional: return "bell.circle"
        case .ephemeral: return "bell.circle"
        @unknown default: return "questionmark.circle"
        }
    }

    private var authorizationColor: Color {
        switch authorizationStatus {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        case .provisional, .ephemeral: return .yellow
        @unknown default: return .gray
        }
    }

    private var authorizationStatusText: String {
        switch authorizationStatus {
        case .authorized: return "Notifications are enabled"
        case .denied: return "Notifications are disabled"
        case .notDetermined: return "Not yet requested"
        case .provisional: return "Provisional access"
        case .ephemeral: return "Ephemeral access"
        @unknown default: return "Unknown status"
        }
    }

    // MARK: - Actions

    private func loadNotificationSettings() async {
        authorizationStatus = await NotificationManager.shared.getAuthorizationStatus()
        pendingNotificationCount = await NotificationManager.shared.getPendingNotificationCount()
    }

    private func requestAuthorization() async {
        let granted = await NotificationManager.shared.requestAuthorization()
        authorizationStatus = await NotificationManager.shared.getAuthorizationStatus()

        if granted {
            alertMessage = "Notifications are now enabled. You'll receive reminders for your tasks."
        } else {
            alertMessage = "Notification permission was denied. You can enable it later in Settings."
        }
        showingAlert = true
    }

    private func clearAllNotifications() async {
        await NotificationManager.shared.cancelAllNotifications()
        pendingNotificationCount = await NotificationManager.shared.getPendingNotificationCount()
        alertMessage = "All scheduled notifications have been cleared."
        showingAlert = true
    }
}

#Preview {
    NotificationSettingsView()
}
