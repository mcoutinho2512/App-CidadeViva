//
//  MockData.swift
//  CidadeViva
//
//  Dados mockados para desenvolvimento e demonstração
//

import Foundation
import CoreLocation

/// Provedor de dados mockados para o aplicativo
enum MockData {

    // MARK: - Weather Mock

    static func mockWeather() -> Weather {
        Weather(
            id: "weather-001",
            temperature: 32.5,
            feelsLike: 35.2,
            condition: .sunny,
            humidity: 75,
            windSpeed: 12.3,
            lastUpdated: Date().addingTimeInterval(-300), // 5 minutos atrás
            location: "Rio de Janeiro - RJ"
        )
    }

    static func mockWeatherDTO() -> WeatherResponseDTO {
        WeatherResponseDTO(
            success: true,
            data: WeatherDataDTO(
                id: "weather-001",
                temperature: 32.5,
                feelsLike: 35.2,
                condition: "sunny",
                humidity: 75,
                windSpeed: 12.3,
                location: "Rio de Janeiro - RJ",
                lastUpdated: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300))
            ),
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Cameras Mock

    static func mockCameras() -> [Camera] {
        [
            Camera(
                id: "cam-001",
                name: "Avenida Atlântica - Copacabana",
                region: "Zona Sul",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -22.9711, longitude: -43.1822),
                streamURL: "https://stream.example.com/cam-001",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-180)
            ),
            Camera(
                id: "cam-002",
                name: "Linha Vermelha - Fundão",
                region: "Zona Norte",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -22.8536, longitude: -43.2428),
                streamURL: "https://stream.example.com/cam-002",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-120)
            ),
            Camera(
                id: "cam-003",
                name: "Túnel Rebouças - Lagoa",
                region: "Zona Sul",
                status: .offline,
                coordinate: CLLocationCoordinate2D(latitude: -22.9625, longitude: -43.2054),
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-3600)
            ),
            Camera(
                id: "cam-004",
                name: "Avenida Brasil - Penha",
                region: "Zona Oeste",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -22.8454, longitude: -43.2881),
                streamURL: "https://stream.example.com/cam-004",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-60)
            ),
            Camera(
                id: "cam-005",
                name: "Ponte Rio-Niterói",
                region: "Centro",
                status: .maintenance,
                coordinate: CLLocationCoordinate2D(latitude: -22.8697, longitude: -43.1629),
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-7200)
            ),
            Camera(
                id: "cam-006",
                name: "Avenida Niemeyer - Leblon",
                region: "Zona Sul",
                status: .online,
                coordinate: CLLocationCoordinate2D(latitude: -22.9964, longitude: -43.2338),
                streamURL: "https://stream.example.com/cam-006",
                thumbnailURL: nil,
                lastUpdate: Date().addingTimeInterval(-90)
            )
        ]
    }

    static func mockCamerasDTO() -> CamerasResponseDTO {
        let cameras = [
            CameraDataDTO(
                id: "cam-001",
                name: "Avenida Atlântica - Copacabana",
                region: "Zona Sul",
                status: "online",
                latitude: -22.9711,
                longitude: -43.1822,
                streamURL: "https://stream.example.com/cam-001",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-180))
            ),
            CameraDataDTO(
                id: "cam-002",
                name: "Linha Vermelha - Fundão",
                region: "Zona Norte",
                status: "online",
                latitude: -22.8536,
                longitude: -43.2428,
                streamURL: "https://stream.example.com/cam-002",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-120))
            ),
            CameraDataDTO(
                id: "cam-003",
                name: "Túnel Rebouças - Lagoa",
                region: "Zona Sul",
                status: "offline",
                latitude: -22.9625,
                longitude: -43.2054,
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600))
            ),
            CameraDataDTO(
                id: "cam-004",
                name: "Avenida Brasil - Penha",
                region: "Zona Oeste",
                status: "online",
                latitude: -22.8454,
                longitude: -43.2881,
                streamURL: "https://stream.example.com/cam-004",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-60))
            ),
            CameraDataDTO(
                id: "cam-005",
                name: "Ponte Rio-Niterói",
                region: "Centro",
                status: "maintenance",
                latitude: -22.8697,
                longitude: -43.1629,
                streamURL: nil,
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200))
            ),
            CameraDataDTO(
                id: "cam-006",
                name: "Avenida Niemeyer - Leblon",
                region: "Zona Sul",
                status: "online",
                latitude: -22.9964,
                longitude: -43.2338,
                streamURL: "https://stream.example.com/cam-006",
                thumbnailURL: nil,
                lastUpdate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-90))
            )
        ]

        return CamerasResponseDTO(
            success: true,
            data: cameras,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    // MARK: - Alerts Mock

    static func mockAlerts() -> [Alert] {
        [
            Alert(
                id: "alert-001",
                type: .traffic,
                severity: .high,
                title: "Congestionamento na Linha Vermelha",
                description: "Trânsito intenso entre o Fundão e a Ilha do Governador. Tempo estimado de atraso: 35 minutos.",
                location: "Linha Vermelha - Zona Norte",
                coordinate: CLLocationCoordinate2D(latitude: -22.8536, longitude: -43.2428),
                createdAt: Date().addingTimeInterval(-1800), // 30 minutos atrás
                expiresAt: Date().addingTimeInterval(7200), // Expira em 2 horas
                isActive: true
            ),
            Alert(
                id: "alert-002",
                type: .weather,
                severity: .medium,
                title: "Possibilidade de Chuva Forte",
                description: "Previsão de chuva forte para as próximas 2 horas na Zona Sul.",
                location: "Zona Sul - Rio de Janeiro",
                coordinate: CLLocationCoordinate2D(latitude: -22.9711, longitude: -43.1822),
                createdAt: Date().addingTimeInterval(-600), // 10 minutos atrás
                expiresAt: Date().addingTimeInterval(7200),
                isActive: true
            ),
            Alert(
                id: "alert-003",
                type: .event,
                severity: .low,
                title: "Evento em Copacabana",
                description: "Show na praia programado para hoje às 19h. Possíveis interdições de vias.",
                location: "Avenida Atlântica - Copacabana",
                coordinate: CLLocationCoordinate2D(latitude: -22.9711, longitude: -43.1822),
                createdAt: Date().addingTimeInterval(-3600), // 1 hora atrás
                expiresAt: Date().addingTimeInterval(10800),
                isActive: true
            ),
            Alert(
                id: "alert-004",
                type: .infrastructure,
                severity: .medium,
                title: "Obra no Túnel Rebouças",
                description: "Manutenção de túnel com interdição de faixa. Reduza a velocidade.",
                location: "Túnel Rebouças - Lagoa",
                coordinate: CLLocationCoordinate2D(latitude: -22.9625, longitude: -43.2054),
                createdAt: Date().addingTimeInterval(-7200), // 2 horas atrás
                expiresAt: nil, // Sem data de expiração
                isActive: true
            ),
            Alert(
                id: "alert-005",
                type: .emergency,
                severity: .critical,
                title: "Acidente na Avenida Brasil",
                description: "Acidente grave envolvendo 3 veículos. Via parcialmente interditada. Desvie pela Linha Amarela.",
                location: "Avenida Brasil - Penha",
                coordinate: CLLocationCoordinate2D(latitude: -22.8454, longitude: -43.2881),
                createdAt: Date().addingTimeInterval(-300), // 5 minutos atrás
                expiresAt: Date().addingTimeInterval(3600),
                isActive: true
            )
        ]
    }

    static func mockAlertsDTO() -> AlertsResponseDTO {
        let alerts = [
            AlertDataDTO(
                id: "alert-001",
                type: "traffic",
                severity: "high",
                title: "Congestionamento na Linha Vermelha",
                description: "Trânsito intenso entre o Fundão e a Ilha do Governador. Tempo estimado de atraso: 35 minutos.",
                location: "Linha Vermelha - Zona Norte",
                latitude: -22.8536,
                longitude: -43.2428,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-002",
                type: "weather",
                severity: "medium",
                title: "Possibilidade de Chuva Forte",
                description: "Previsão de chuva forte para as próximas 2 horas na Zona Sul.",
                location: "Zona Sul - Rio de Janeiro",
                latitude: -22.9711,
                longitude: -43.1822,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-600)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(7200)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-003",
                type: "event",
                severity: "low",
                title: "Evento em Copacabana",
                description: "Show na praia programado para hoje às 19h. Possíveis interdições de vias.",
                location: "Avenida Atlântica - Copacabana",
                latitude: -22.9711,
                longitude: -43.1822,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(10800)),
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-004",
                type: "infrastructure",
                severity: "medium",
                title: "Obra no Túnel Rebouças",
                description: "Manutenção de túnel com interdição de faixa. Reduza a velocidade.",
                location: "Túnel Rebouças - Lagoa",
                latitude: -22.9625,
                longitude: -43.2054,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200)),
                expiresAt: nil,
                isActive: true
            ),
            AlertDataDTO(
                id: "alert-005",
                type: "emergency",
                severity: "critical",
                title: "Acidente na Avenida Brasil",
                description: "Acidente grave envolvendo 3 veículos. Via parcialmente interditada. Desvie pela Linha Amarela.",
                location: "Avenida Brasil - Penha",
                latitude: -22.8454,
                longitude: -43.2881,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-300)),
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
                isActive: true
            )
        ]

        return AlertsResponseDTO(
            success: true,
            data: alerts,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
