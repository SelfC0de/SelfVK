import SwiftUI

enum Brand {
    static let accent = Color(hex: 0x95B806)
    static let foreground = Color(hex: 0xEAEAEA)
    static let background = Color(hex: 0x090A0B)
    static let panel = Color(hex: 0x121416)
    static let elevated = Color(hex: 0x1A1D20)
    static let subtle = Color.white.opacity(0.62)
    static let border = Color.white.opacity(0.09)
    static let danger = Color(hex: 0xFF5A52)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
