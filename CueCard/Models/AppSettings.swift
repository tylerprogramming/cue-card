import SwiftUI

@Observable
final class AppSettings {
    var fontSize: CGFloat = 28
    var textColorHex: String = "#FFFFFF" {
        didSet { _textColor = Color(hex: textColorHex) ?? .white }
    }
    var backgroundColorHex: String = "#000000" {
        didSet { _backgroundColor = Color(hex: backgroundColorHex) ?? .black }
    }
    var backgroundOpacity: Double = 0.85
    var scrollSpeed: Double = 1.0
    var windowWidth: CGFloat = 400
    var windowHeight: CGFloat = 300

    private(set) var _textColor: Color = .white
    private(set) var _backgroundColor: Color = .black

    var textColor: Color { _textColor }
    var backgroundColor: Color { _backgroundColor }

    private enum Keys {
        static let fontSize = "cuecard_fontSize"
        static let textColor = "cuecard_textColor"
        static let bgColor = "cuecard_bgColor"
        static let bgOpacity = "cuecard_bgOpacity"
        static let scrollSpeed = "cuecard_scrollSpeed"
        static let windowWidth = "cuecard_windowWidth"
        static let windowHeight = "cuecard_windowHeight"
    }

    init() {
        let defaults = UserDefaults.standard
        if let v = defaults.object(forKey: Keys.fontSize) as? CGFloat { fontSize = v }
        if let v = defaults.string(forKey: Keys.textColor) { textColorHex = v }
        if let v = defaults.string(forKey: Keys.bgColor) { backgroundColorHex = v }
        if let v = defaults.object(forKey: Keys.bgOpacity) as? Double { backgroundOpacity = v }
        if let v = defaults.object(forKey: Keys.scrollSpeed) as? Double { scrollSpeed = v }
        if let v = defaults.object(forKey: Keys.windowWidth) as? CGFloat { windowWidth = v }
        if let v = defaults.object(forKey: Keys.windowHeight) as? CGFloat { windowHeight = v }

        _textColor = Color(hex: textColorHex) ?? .white
        _backgroundColor = Color(hex: backgroundColorHex) ?? .black
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(fontSize, forKey: Keys.fontSize)
        defaults.set(textColorHex, forKey: Keys.textColor)
        defaults.set(backgroundColorHex, forKey: Keys.bgColor)
        defaults.set(backgroundOpacity, forKey: Keys.bgOpacity)
        defaults.set(scrollSpeed, forKey: Keys.scrollSpeed)
        defaults.set(windowWidth, forKey: Keys.windowWidth)
        defaults.set(windowHeight, forKey: Keys.windowHeight)
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        guard hexSanitized.count == 6 else { return nil }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
