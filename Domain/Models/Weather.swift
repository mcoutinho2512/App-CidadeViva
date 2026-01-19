//
//  Weather.swift
//  CidadeViva
//
//  Modelo de domínio para dados climáticos
//

import Foundation

/// Representa as informações climáticas da cidade
struct Weather: Identifiable, Equatable {

    // MARK: - Properties

    let id: String
    let temperature: Double
    let feelsLike: Double
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let lastUpdated: Date
    let location: String

    // MARK: - Computed Properties

    /// Temperatura formatada em Celsius
    var temperatureFormatted: String {
        "\(Int(temperature))°"
    }

    /// Sensação térmica formatada
    var feelsLikeFormatted: String {
        "Sensação: \(Int(feelsLike))°"
    }

    /// Umidade formatada
    var humidityFormatted: String {
        "\(humidity)%"
    }

    /// Velocidade do vento formatada
    var windSpeedFormatted: String {
        "\(Int(windSpeed)) km/h"
    }

    /// Última atualização formatada
    var lastUpdatedFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}

// MARK: - Weather Condition

/// Condições climáticas possíveis
enum WeatherCondition: String, Codable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case stormy = "stormy"
    case partlyCloudy = "partly_cloudy"
    case foggy = "foggy"

    /// Ícone SF Symbol correspondente
    var iconName: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .stormy:
            return "cloud.bolt.rain.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .foggy:
            return "cloud.fog.fill"
        }
    }

    /// Descrição legível
    var description: String {
        switch self {
        case .sunny:
            return "Ensolarado"
        case .cloudy:
            return "Nublado"
        case .rainy:
            return "Chuvoso"
        case .stormy:
            return "Tempestade"
        case .partlyCloudy:
            return "Parcialmente Nublado"
        case .foggy:
            return "Neblina"
        }
    }
}
