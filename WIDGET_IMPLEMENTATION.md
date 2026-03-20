# TaskMaster iOS Widgets - Implementation Complete

## 功能概述

TaskMaster 现已支持 iOS 主屏幕小组件，用户可以直接在主屏幕查看任务信息。

### 支持的小组件尺寸

#### Small (2x2)
- 显示任务总数
- 显示当前小组件类型（Today/Pending/Overdue）
- 点击跳转到应用

#### Medium (4x2)
- 显示前 4 个任务
- 任务标题和优先级
- 截止日期显示
- 完成百分比

#### Large (4x4)
- 显示前 6 个任务
- 优先级统计分布
- 任务分类信息
- 子任务计数预留

### 小组件类型

1. **Today** - 显示今天到期的任务
2. **Pending** - 显示所有未完成任务
3. **Overdue** - 显示逾期任务
4. **By Category** - 按分类显示（可配置具体分类）

---

## 技术实现

### 文件结构

```
TaskMasterWidgets/
├── TaskMasterWidgets.swift          # 主 Widget 入口
├── TaskMasterWidgetBundle.swift      # Widget Bundle
├── README.md                        # Widget 说明文档
└── Providers/
    ├── SimpleEntry.swift             # Timeline Entry 定义
    ├── WidgetModels.swift            # Widget 数据模型
    └── WidgetTimelineProvider.swift  # 数据提供者
Views/
    ├── SmallWidgetView.swift
    ├── MediumWidgetView.swift
    └── LargeWidgetView.swift
```

### 主应用修改

**新增文件**:
- `TaskMaster/Models/WidgetModels.swift` - WidgetTask 和 WidgetConfiguration 模型
- `TaskMaster/Models/WidgetDataManager.swift` - 管理与 Widget 的数据共享

**修改文件**:
- `TaskMaster/Views/TaskListView.swift` - 在任务变化时更新 Widget
- `TaskMaster/Views/SettingsView.swift` - 添加 Widget 配置选项

### 数据共享

Widget 通过 App Group 共享数据：
- Shared UserDefaults Suite: `group.com.taskmaster.app`
- 数据序列化到 JSON 格式
- 主应用更新数据后通知 Widget 刷新

### Timeline 刷新策略

- 每 30 分钟自动刷新
- 主应用数据变化时手动刷新
- Widget 配置变化时刷新

---

## 使用方法

### 在主应用中配置 Widget

1. 打开设置页
2. 找到 "Widget" section
3. 选择 Widget 类型：
   - Today - 显示今日任务
   - Pending - 显示所有待办
   - Overdue - 显示逾期任务
   - By Category - 按分类筛选

### 添加到主屏幕

1. 长按主屏幕空白处
2. 点击左上角 "+" 按钮
3. 搜索 "TaskMaster"
4. 选择合适的小组件尺寸
5. 点击 "添加小组件"

---

## 配置要求

### App Group
必须在 Xcode 中为以下 Target 配置 App Group：
- `TaskMaster` (主应用)
- `TaskMasterWidgets` (Widget Extension)

App Group 标识符：`group.com.taskmaster.app`

### 权限
Widget Extension 需要以下权限：
- App Groups (用于数据共享)

---

## 已知限制

1. **数据同步延迟**: Widget 最快 15 分钟刷新一次
2. **有限交互**: Widget 仅支持点击跳转，不支持直接编辑任务
3. **数据大小限制**: Shared UserDefaults 有大小限制（通常几 MB）
4. **无深度链接**: 点击 Widget 会打开主应用，但无法直接跳转到特定任务（预留）

---

## 未来增强

- [ ] 深度链接支持 - 点击任务直接打开详情
- [ ] 快速完成按钮 - 在 Widget 中直接标记任务完成
- [ ] 更多小组件样式 - 不同设计风格
- [ ] 每日提醒 - 显示今日完成的进度
- [ ] 锁屏小组件 - iOS 16+ 锁屏小组件支持

---

## 调试

### 查看 Widget 日志

```swift
import os.log
let logger = Logger(subsystem: "com.taskmaster.widget", category: "Widget")

logger.log("Widget refreshed with \(tasks.count) tasks")
```

### 手动刷新 Widget

```swift
WidgetCenter.shared.reloadAllTimelines()
```

### 调试数据

在模拟器中，可以使用以下命令查看 Shared UserDefaults：
```bash
xcrun simctl get_app_container booted group.com.taskmaster.app data
```
