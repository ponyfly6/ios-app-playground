import Foundation
import SwiftData
import SwiftUI

@Model
final class SubTask: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var parentTask: TaskItem?

    init(title: String, parentTask: TaskItem? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.parentTask = parentTask
    }
}
