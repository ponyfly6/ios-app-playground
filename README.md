# TaskMaster

<div align="center">

A modern, feature-rich iOS task management application built with SwiftUI and SwiftData.

[![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.9-orange.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-Persistence-green.svg)](https://developer.apple.com/documentation/swiftdata)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

</div>

---

## ✨ Features

### Core Functionality

- **Task Management** - Full CRUD operations for tasks with rich metadata
- **Priority System** - Three levels (Low/Medium/High) with visual color indicators
- **Category System** - Custom categories with selectable icons and colors
- **Due Dates** - Optional due dates with overdue highlighting
- **Subtasks** - Nested task structure with independent completion states
- **Local Notifications** - Flexible reminder options (on due date, 1/2/7 days before)

### Search, Filter & Sort

- **Fuzzy Search** - Search by task title and description
- **Smart Filters** - Filter by priority, category, and completion status
- **Multiple Sort Options** - Sort by created date, due date, priority, or title

### Advanced Operations

- **Context Menu Actions** - Long press for quick actions:
  - Duplicate task
  - Move to category
  - Complete all subtasks
  - Copy title to clipboard
  - Quick mark complete
- **Batch Operations** - Multi-select mode for bulk actions:
  - Batch complete/uncomplete
  - Batch move category
  - Batch change priority
  - Batch delete with confirmation
- **Data Export** - Export tasks in JSON or CSV format

### Analytics & Statistics

- **Statistics Dashboard** - Overview of task metrics
  - Total, completed, and pending counts
  - Overdue task warnings
  - Completion percentage
  - Priority distribution visualization
  - Category-wise task breakdown

### iOS Widgets

- **Multiple Sizes** - Small, Medium, and Large widgets
- **Widget Types**:
  - Today Tasks - Shows tasks due today
  - Pending Tasks - Shows all incomplete tasks
  - Overdue Tasks - Shows past-due tasks
  - By Category - Filter by specific category
- **Auto Sync** - Data updates reflect in widgets automatically

### UI/UX

- Clean, native iOS design following Human Interface Guidelines
- Swipe actions for quick complete/delete
- Empty state and no-results views
- Dark mode support via system colors
- Smooth animations and transitions

---

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Declarative UI framework |
| **SwiftData** | Persistence layer (@Model, @Query) |
| **WidgetKit** | iOS Home Screen Widgets |
| **UserNotifications** | Local notification management |
| **@Observable** | iOS 17 Observation framework |
| **MVVM** | Architecture pattern |
| **App Groups** | Data sharing between app and widgets |

---

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

---

## 🚀 Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/TaskMaster.git
   ```

2. Open `Package.swift` in Xcode

3. Build and run on iOS Simulator or device

---

## 📂 Project Structure

```
TaskMaster/
├── TaskMasterApp.swift              # App entry point
├── Models/
│   ├── TaskItem.swift               # Task model + Priority enum
│   ├── TaskCategory.swift           # Category model + Color extensions
│   ├── SubTask.swift                # Subtask model
│   ├── NotificationManager.swift    # Notification management
│   ├── ExportManager.swift          # Data export (JSON/CSV)
│   ├── WidgetDataManager.swift      # Widget data synchronization
│   └── WidgetModels.swift           # Widget-specific models
├── ViewModels/
│   ├── TaskListViewModel.swift      # List logic (filter/sort)
│   └── StatisticsViewModel.swift    # Statistics computation
├── Views/
│   ├── TaskListView.swift           # Main task list
│   ├── TaskDetailView.swift         # Task detail editing
│   ├── AddTaskView.swift            # Create task form
│   ├── AddCategoryView.swift        # Create category form
│   ├── SettingsView.swift           # Filter/sort settings
│   ├── StatisticsView.swift         # Statistics dashboard
│   ├── CategoryManagementView.swift # Category management
│   ├── NotificationSettingsView.swift # Notification preferences
│   ├── ExportView.swift             # Data export interface
│   ├── BatchOperationsView.swift    # Batch operations UI
│   ├── SubTaskListView.swift        # Subtask management
│   ├── ContextMenuActions.swift     # Context menu actions
│   └── Components/
│       ├── TaskRowView.swift        # Reusable task row
│       ├── TaskRowViewContent.swift # Row content layout
│       └── TaskSelectionRow.swift   # Selection row for batch ops
└── Resources/
    └── Assets.xcassets/             # Images and colors

TaskMasterWidgets/
├── TaskMasterWidgets.swift          # Widget entry point
├── TaskMasterWidgetBundle.swift     # Widget bundle
├── Providers/
│   ├── SimpleEntry.swift            # Timeline entry
│   ├── WidgetModels.swift           # Widget data models
│   └── WidgetTimelineProvider.swift # Timeline refresh logic
└── Views/
    ├── SmallWidgetView.swift        # Small widget layout
    ├── MediumWidgetView.swift       # Medium widget layout
    └── LargeWidgetView.swift        # Large widget layout
```

---

## 📸 Screenshots

*(Screenshots to be added)*

---

## 🎯 Usage

### Creating Tasks

1. Tap the `+` button in the main screen
2. Fill in task details:
   - Title (required)
   - Description (optional)
   - Due date (optional)
   - Priority (Low/Medium/High)
   - Category (optional)
   - Subtasks (optional)
   - Reminder setting (optional)
3. Tap "Add Task" to save

### Managing Categories

1. Go to Settings → Manage Categories
2. Tap `+` to create a new category
3. Customize name, icon, and color
4. Edit or delete existing categories
   - Deleting a category resets associated tasks to uncategorized

### Batch Operations

1. Tap the "Edit" button in the task list
2. Select multiple tasks
3. Choose an action from the bottom toolbar:
   - Mark Complete/Incomplete
   - Change Category
   - Change Priority
   - Complete All Subtasks
   - Delete

### Using Widgets

1. Long press on your home screen
2. Tap the `+` button to add a widget
3. Search for "TaskMaster"
4. Select widget size and type
5. Add to your home screen
6. Configure widget type in app settings

### Exporting Data

1. Go to Settings → Export Data
2. Choose format (JSON or CSV)
3. Preview the export data
4. Tap "Share" to export via AirDrop, Files, or other apps

---

## 🔧 Configuration

### App Groups

Widgets require App Groups to share data between the main app and widget extension:

1. Enable App Groups capability for the main app target
2. Enable App Groups capability for the widget extension
3. Use the shared suite name: `group.com.taskmaster.app`

### Notification Permissions

The app requests notification permissions on first launch. Reminders require:

- Local notification permission granted
- App in background or foreground when reminder fires

---

## 📊 Code Statistics

- **Total Files**: 35+
- **Lines of Code**: ~4,000+
- **SwiftUI Views**: 18
- **Data Models**: 6
- **ViewModels**: 2
- **Manager Classes**: 3

---

## 🗺 Roadmap

See [FUTURE_FEATURES.md](FUTURE_FEATURES.md) for planned features:

- [ ] Recurring tasks
- [ ] iCloud sync
- [ ] Task tags
- [ ] Siri Shortcuts
- [ ] Data import
- [ ] Time tracking
- [ ] Attachments support
- [ ] Custom themes

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">

Built with ❤️ using SwiftUI

</div>
