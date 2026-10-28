import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Consecrated Devotional Palette
    static let spiritualSaffron = Color(hex: "FF9933")
    static let spiritualSaffronDark = Color(hex: "E67E22")
    static let spiritualGold = Color(hex: "FFD700")
    static let spiritualCreamBg = Color(hex: "FFFDF9")
    static let spiritualCardBg = Color.white
    static let spiritualTextPrimary = Color(hex: "2C3E50")
    static let spiritualTextSecondary = Color(hex: "7F8C8D")
    static let spiritualDivider = Color(hex: "F0E6D2")
    static let spiritualSaffronLight = Color(hex: "FFF4E6")
    static let spiritualEmerald = Color(hex: "27AE60")
}

public enum SpiritualGradients {
    public static let saffron = LinearGradient(
        colors: [Color.spiritualSaffron, Color.spiritualSaffronDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let golden = LinearGradient(
        colors: [Color.spiritualGold, Color.spiritualSaffron],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let softBackground = LinearGradient(
        colors: [Color.spiritualCreamBg, Color(hex: "FFF8EE")],
        startPoint: .top,
        endPoint: .bottom
    )
}

public struct SpiritualCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var elevation: CGFloat = 6
    var strokeColor: Color = Color.spiritualDivider.opacity(0.6)
    
    public func body(content: Content) -> some View {
        content
            .background(Color.spiritualCardBg)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: elevation, x: 0, y: elevation / 2)
    }
}

public extension View {
    func spiritualCard(cornerRadius: CGFloat = 16, elevation: CGFloat = 5) -> some View {
        self.modifier(SpiritualCardModifier(cornerRadius: cornerRadius, elevation: elevation))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
