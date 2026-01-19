//
//  AppConfiguration.swift
//  CidadeViva
//
//  Configurações globais do aplicativo
//

import Foundation

/// Configurações centralizadas do aplicativo
enum AppConfiguration {

    // MARK: - API Configuration

    enum API {
        static let baseURL = "https://api.cidadeviva.com.br"
        static let version = "v1"
        static let timeout: TimeInterval = 30.0

        static var fullBaseURL: String {
            "\(baseURL)/api/\(version)"
        }
    }

    // MARK: - App Information

    enum AppInfo {
        static let name = "CidadeViva"
        static let bundleIdentifier = "com.cidadeviva.ios"
        static let version = "1.0.0"
        static let buildNumber = "1"
    }

    // MARK: - Feature Flags

    enum Features {
        static let enableMockData = true // Habilitar dados mockados
        static let enableNetworkLogging = true // Logging de rede (apenas DEBUG)
        static let enableAutoRefresh = true // Refresh automático dos dados
        static let autoRefreshInterval: TimeInterval = 300 // 5 minutos
    }

    // MARK: - UI Configuration

    enum UI {
        static let animationDuration: Double = 0.3
        static let cardCornerRadius: CGFloat = 12
        static let cardShadowRadius: CGFloat = 4
        static let defaultPadding: CGFloat = 16
    }

    // MARK: - Map Configuration

    enum Map {
        static let defaultLatitude: Double = -23.5505 // São Paulo (exemplo)
        static let defaultLongitude: Double = -46.6333
        static let defaultZoomLevel: Double = 0.05
    }

    // MARK: - Cache Configuration

    enum Cache {
        static let expirationTime: TimeInterval = 600 // 10 minutos
        static let maxCacheSize: Int = 100 // Número máximo de itens em cache
    }
}
