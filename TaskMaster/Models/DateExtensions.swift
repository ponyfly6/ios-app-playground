import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isPast: Bool {
        self < Date()
    }
    
    var relativeString: String {
        if isToday { return "Today" }
        if isTomorrow { return "Tomorrow" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
