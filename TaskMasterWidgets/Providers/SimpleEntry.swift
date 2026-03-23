import WidgetKit
import SwiftUI

// MARK: - Widget Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let configuration: WidgetConfiguration
}

// MARK: - Color Extensions

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard let hexCode = Int(hexSanitized, radix: 16) else { return nil }

        let red = Double((hexCode >> 16) & 0xFF) / 255
        let green = Double((hexCode >> 8) & 0xFF) / 255
        let blue = Double(hexCode & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
