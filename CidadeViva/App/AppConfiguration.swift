import SwiftUI

enum AppConfiguration {
    static let appName = "Cidade Viva"

    // MARK: - Nova Paleta de Cores

    // Cores Primárias
    static let primaryOrange = Color(hex: "FFA94D")  // Dourado suave
    static let primaryBlue = Color(hex: "4F46E5")    // Azul vibrante

    // Backgrounds
    static let backgroundPrimary = Color(hex: "F8FAFC")   // Off-white
    static let backgroundCard = Color.white
    static let backgroundDark = Color(hex: "1E293B")      // Header dark

    // Textos
    static let textPrimary = Color(hex: "1E293B")
    static let textSecondary = Color(hex: "64748B")
    static let textTertiary = Color(hex: "94A3B8")

    // Status
    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")

    // Gradientes
    static let gradientSunset = LinearGradient(
        colors: [Color(hex: "FFA94D"), Color(hex: "FF6B95")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientOcean = LinearGradient(
        colors: [Color(hex: "4F46E5"), Color(hex: "06B6D4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientSuccess = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "059669")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Tab Bar
    static let tabBarBackground = Color(hex: "FFFBF5")  // Creme suave
    static let tabBarSelected = Color(hex: "FFA94D")
    static let tabBarUnselected = Color(hex: "94A3B8")

    // Legado (manter compatibilidade)
    static let primaryYellow = primaryOrange
    static let headerDark = backgroundDark
    static let cardBackground = backgroundCard

    // API
    static let apiBaseURL = "https://api.cidadeviva.gov.br"
    static let apiVersion = "v1"

    static var fullAPIURL: String {
        "\(apiBaseURL)/\(apiVersion)"
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
}
