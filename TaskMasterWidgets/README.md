# TaskMaster Widgets

iOS Home Screen Widgets for TaskMaster application.

---

## 📱 Widget Overview

TaskMaster Widgets provide quick access to your tasks directly from your home screen. They automatically sync with the main app and update when your task data changes.

---

## 📏 Widget Sizes

### Small Widget (2x2)
- Displays task count summary
- Shows widget type icon
- Tappable to open app
- Minimalist design

### Medium Widget (4x2)
- Shows up to 4 tasks
- Displays task title and priority
- Shows due dates
- Displays completion percentage

### Large Widget (4x4)
- Shows up to 6 tasks
- Priority distribution visualization
- Category information
- Subtask count display
- Rich task details

---

## 🎯 Widget Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Today Tasks** | Tasks due today | Daily focus |
| **Pending Tasks** | All incomplete tasks | Overall progress |
| **Overdue Tasks** | Past-due tasks | Urgent items |
| **By Category** | Filter by specific category | Category-specific view |

---

## ⚙️ Configuration

### App Groups Setup

Widgets share data with the main app via App Groups. To enable:

1. **Main App**:
   - Select the TaskMaster target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "App Groups"
   - Create group: `group.com.taskmaster.app`

2. **Widget Extension**:
   - Select the TaskMasterWidgets target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "App Groups"
   - Add the same group: `group.com.taskmaster.app`

### Shared Data Keys

The widget uses shared UserDefaults with these keys:

| Key | Type | Description |
|-----|------|-------------|
| `tasks` | JSON | Array of WidgetTask objects |
| `widgetType` | String | Widget type (today/pending/overdue/byCategory) |
| `widgetCategoryID` | String | Optional category ID for filtering |
| `categories` | JSON | Array of category data |

---

## 🔄 Updating Widgets

### Automatic Updates

Widgets update automatically when tasks change in the main app:

```swift
// Call this when tasks are modified
await WidgetDataManager.shared.updateWidgetData(tasks: allTasks)
```

This process:
1. Encodes tasks to JSON
2. Saves to shared UserDefaults
3. Triggers widget timeline reload

### Timeline Refresh

- Minimum refresh interval: 15-30 minutes (iOS system limit)
- Data changes trigger immediate updates
- Pull-to-refresh in app updates all widgets

---

## 🏗 Architecture

```
TaskMasterWidgets/
├── TaskMasterWidgets.swift          # Widget entry point
├── TaskMasterWidgetBundle.swift     # Widget bundle configuration
├── Providers/
│   ├── SimpleEntry.swift            # Timeline entry model
│   ├── WidgetModels.swift           # Widget-specific data models
│   └── WidgetTimelineProvider.swift # Timeline refresh logic
└── Views/
    ├── SmallWidgetView.swift        # Small widget layout
    ├── MediumWidgetView.swift       # Medium widget layout
    └── LargeWidgetView.swift        # Large widget layout
```

### Key Components

- **WidgetTimelineProvider**: Manages widget refresh schedules
- **WidgetDataManager**: Syncs data between app and widgets
- **Widget Models**: Lightweight models for widget display
- **Widget Views**: Size-specific UI implementations

---

## 🔧 Customization

### Modifying Widget Types

To add a new widget type:

1. Add the type to `WidgetType` enum in `WidgetModels.swift`
2. Implement filtering logic in `WidgetTimelineProvider.swift`
3. Add UI option in main app settings
4. Update widget views to display the new type

### Changing Refresh Schedule

Modify `getTimeline()` in `WidgetTimelineProvider.swift`:

```swift
let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
let entry = SimpleEntry(date: refreshDate, ...)
return Timeline(entries: [entry], policy: .atEnd)
```

---

## 🚨 Limitations

| Limitation | Description | Workaround |
|------------|-------------|------------|
| **SwiftData Access** | Widgets have limited access to SwiftData | Use shared UserDefaults with JSON serialization |
| **Refresh Rate** | System limits refresh to 15-30 minutes | Trigger updates when data changes |
| **Interactive Actions** | Limited interactivity in widgets | Tap to open app for full actions |
| **Data Size** | UserDefaults has size limits | Store only essential data |

---

## 🎨 Design Guidelines

- **Consistency**: Follow main app color scheme and typography
- **Clarity**: Prioritize readability over decoration
- **Hierarchy**: Use size and color to indicate importance
- **Space**: Maintain adequate padding and spacing
- **Icons**: Use SF Symbols for consistency

---

## 🧪 Testing

### Testing Widgets in Simulator

1. Add widget to home screen in Simulator
2. Make changes in the main app
3. Verify widget updates
4. Test different widget types and sizes

### Debugging Widget Updates

Enable WidgetKit debugging:

```bash
# In Terminal, run before launching Simulator
defaults write com.apple.dt.Xcode IDEDebugInteractionsWhileDebugging 1
```

Then in Xcode:
1. Run the widget extension target
2. Use "Debug View Hierarchy" to inspect widget layout
3. Check Console for timeline refresh logs

---

## 📚 Related Documentation

- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Creating Widgets](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

---

## 🔗 Integration with Main App

The main app handles:

- Widget type selection in settings
- Data synchronization via `WidgetDataManager`
- Deep linking from widget taps
- Timeline refresh triggers

See `SettingsView.swift` and `WidgetDataManager.swift` in the main app for implementation details.
