# TaskMaster

A modern iOS task management application built with SwiftUI and SwiftData.

## Features

### Core Functionality
- **Task CRUD Operations** - Create, read, update, and delete tasks
- **Priority System** - Three levels (Low/Medium/High) with visual color indicators
- **Category System** - Custom categories with selectable icons and colors
- **Due Dates** - Optional due dates with overdue highlighting

### Search, Filter & Sort
- **Search** - Fuzzy search by task title and description
- **Filter** - Filter by priority, category, and completion status
- **Sort** - Sort by created date, due date, priority, or title

### UI/UX
- Clean, native iOS design following Human Interface Guidelines
- Swipe actions for quick complete/delete
- Empty state and no-results views
- Dark mode support via system colors

## Tech Stack

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| SwiftData | Persistence layer (@Model, @Query) |
| @Observable | iOS 17 Observation framework |
| MVVM | Architecture pattern |

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Build and run on iOS Simulator or device

## Project Structure

```
TaskMaster/
├── TaskMasterApp.swift          # App entry point
├── Models/
│   ├── TaskItem.swift           # Task model + Priority enum
│   ├── TaskCategory.swift       # Category model + Color extensions
│   └── DateExtensions.swift     # Date utility extensions
├── ViewModels/
│   └── TaskListViewModel.swift  # List logic (filter/sort)
├── Views/
│   ├── TaskListView.swift       # Main task list
│   ├── AddTaskView.swift        # Create task form
│   ├── AddCategoryView.swift    # Create category form
│   ├── SettingsView.swift       # Filter/sort settings
│   └── Components/
│       └── TaskRowView.swift    # Reusable task row
└── Resources/
    └── Assets.xcassets/
```

## License

MIT License
