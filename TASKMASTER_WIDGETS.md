# TaskMaster - iOS Widgets

## 小组件功能规划

### 小组件尺寸和功能

#### Small Widget (2x2)
- 显示今日任务数量
- 显示待办任务数量
- 点击跳转到应用

#### Medium Widget (4x2)
- 显示前 3-4 个待办任务
- 显示任务标题和优先级
- 快速完成按钮（使用 Link）

#### Large Widget (4x4)
- 显示今日任务列表
- 按优先级排序
- 显示截止时间
- 完成进度指示器

### 配置选项
- **Today Tasks**: 显示今天到期的任务
- **Pending Tasks**: 显示所有未完成任务
- **Overdue Tasks**: 显示逾期任务
- **By Category**: 按分类显示
- **High Priority**: 只显示高优先级任务

---

## 技术实现

### 文件结构
```
TaskMasterWidgets/
├── TaskMasterWidgets.swift
├── TaskMasterWidgetBundle.swift
├── Providers/
│   ├── SimpleEntry.swift
│   └── TimelineProvider.swift
└── Views/
    ├── SmallWidgetView.swift
    ├── MediumWidgetView.swift
    └── LargeWidgetView.swift
```

### Timeline 策略
- 每 15-30 分钟刷新一次
- 应用进入后台时更新
- 任务变化时通知 Widget 更新
