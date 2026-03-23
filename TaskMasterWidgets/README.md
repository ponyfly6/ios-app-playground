# TaskMaster Widgets

## Widget Configuration

The widget uses shared UserDefaults to communicate between the app and the widget.

### Shared Data Keys
- `tasks`: JSON-encoded array of WidgetTask objects
- `widgetType`: String indicating widget type (today/pending/overdue/byCategory)
- `widgetCategoryID`: Optional category ID for filtering
- `categories`: JSON-encoded array of category data

### Updating the Widget

When tasks change in the main app, call:
```swift
await WidgetDataManager.shared.updateWidgetData(tasks: allTasks)
```

This will:
1. Encode tasks to JSON
2. Save to shared UserDefaults
3. Trigger widget timeline reload

## Widget Types

### Today Tasks
Shows tasks due today

### Pending Tasks
Shows all uncompleted tasks

### Overdue Tasks
Shows tasks past their due date

### By Category
Shows tasks filtered by category

## Setup Instructions

1. Add App Group capability to main app
2. Add App Group capability to widget extension
3. Use shared UserDefaults suite name: "group.com.taskmaster.app"

## Limitations

- Widgets have limited access to SwiftData
- Data must be serialized to JSON/UserDefaults
- Widgets refresh on a timeline (15-30 minutes minimum)
- App Group must be configured for data sharing
