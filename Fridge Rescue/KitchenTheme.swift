import SwiftUI

// Warm, appetizing, theme-independent palette. Every color is explicit RGB so the app
// looks identical regardless of the device's light/dark system appearance.
enum Kitchen {
    static let bg        = Color(red: 0.980, green: 0.960, blue: 0.922)
    static let bgDeep    = Color(red: 0.960, green: 0.930, blue: 0.876)
    static let card      = Color(red: 1.000, green: 1.000, blue: 1.000)
    static let cardAlt   = Color(red: 0.988, green: 0.972, blue: 0.945)

    static let primary   = Color(red: 0.851, green: 0.400, blue: 0.290)   // warm tomato
    static let primaryDk = Color(red: 0.686, green: 0.290, blue: 0.208)
    static let accent    = Color(red: 0.420, green: 0.600, blue: 0.352)   // herb green
    static let accentSoft = Color(red: 0.960, green: 0.902, blue: 0.820)  // soft cream tint
    static let honey     = Color(red: 0.902, green: 0.678, blue: 0.278)

    static let text      = Color(red: 0.200, green: 0.161, blue: 0.129)
    static let textMuted = Color(red: 0.482, green: 0.435, blue: 0.384)
    static let hairline  = Color(red: 0.902, green: 0.863, blue: 0.804)

    // Match states for recipe results.
    static let ready     = Color(red: 0.360, green: 0.620, blue: 0.353)
    static let almost    = Color(red: 0.858, green: 0.620, blue: 0.208)
    static let far       = Color(red: 0.618, green: 0.565, blue: 0.510)

    // Ingredient group accents.
    static let grpVeg    = Color(red: 0.420, green: 0.600, blue: 0.352)
    static let grpFruit  = Color(red: 0.898, green: 0.545, blue: 0.290)
    static let grpProtein = Color(red: 0.780, green: 0.353, blue: 0.318)
    static let grpDairy  = Color(red: 0.898, green: 0.722, blue: 0.353)
    static let grpGrain  = Color(red: 0.792, green: 0.616, blue: 0.353)
    static let grpStaple = Color(red: 0.549, green: 0.502, blue: 0.451)
    static let grpHerb   = Color(red: 0.400, green: 0.616, blue: 0.420)
}

// Friendly, distinctive type without any custom font files or SF Symbols.
extension Font {
    static func kitchenRounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func kitchenSerif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

// Adaptive metrics: gently scale up on iPad without breaking the iPhone layout.
enum Metrics {
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    static var contentMaxWidth: CGFloat { isPad ? 660 : .infinity }
    static var gutter: CGFloat { isPad ? 26 : 18 }
}
