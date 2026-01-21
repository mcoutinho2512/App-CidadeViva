import SwiftUI

enum AppConfiguration {
    static let appName = "Cidade Viva"

    // MARK: - Paleta Institucional/Governamental

    // Cores Primárias - Tons sóbrios e profissionais
    static let primaryBlue = Color(hex: "1E3A5F")       // Azul marinho institucional
    static let secondaryBlue = Color(hex: "2D5A87")     // Azul médio
    static let accentGold = Color(hex: "C9A227")        // Dourado institucional (detalhes)
    static let primaryOrange = accentGold               // Compatibilidade

    // Backgrounds
    static let backgroundPrimary = Color(hex: "F5F7FA") // Cinza muito claro
    static let backgroundCard = Color.white
    static let backgroundDark = Color(hex: "1A1A2E")    // Modo escuro

    // Textos
    static let textPrimary = Color(hex: "2C3E50")       // Texto principal
    static let textSecondary = Color(hex: "6B7C93")     // Texto secundário
    static let textTertiary = Color(hex: "94A3B8")      // Texto terciário

    // Status
    static let success = Color(hex: "27AE60")           // Verde status
    static let warning = Color(hex: "F39C12")           // Amarelo alerta
    static let error = Color(hex: "E74C3C")             // Vermelho crítico

    // Gradientes Institucionais
    static let gradientHeader = LinearGradient(
        colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let gradientSunset = LinearGradient(
        colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientOcean = LinearGradient(
        colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientSuccess = LinearGradient(
        colors: [Color(hex: "27AE60"), Color(hex: "1E8449")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Tab Bar
    static let tabBarBackground = Color.white
    static let tabBarSelected = Color(hex: "1E3A5F")
    static let tabBarUnselected = Color(hex: "94A3B8")

    // Legado (manter compatibilidade)
    static let primaryYellow = accentGold
    static let headerDark = primaryBlue
    static let cardBackground = backgroundCard

    // API
    static let apiBaseURL = "https://api.cidadeviva.gov.br"
    static let apiVersion = "v1"

    static var fullAPIURL: String {
        "\(apiBaseURL)/\(apiVersion)"
    }

    // MARK: - Fonte de Dados

    /// URL base da API REST (Cloud Functions)
    /// Troque pelo seu domínio do Firebase Hosting após deploy
    static let apiURL = "https://cidadeviva-admin.web.app/api"

    /// Define se deve usar a API REST (Cloud Functions)
    /// Se true, ignora useFirebase e busca dados via HTTP
    static let useAPI = false

    /// Define se deve usar Firebase SDK diretamente
    /// Se useAPI for true, esta configuração é ignorada
    static let useFirebase = true
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
