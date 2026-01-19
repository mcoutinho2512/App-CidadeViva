//
//  WeatherDTO.swift
//  CidadeViva
//
//  Data Transfer Object para resposta da API de clima
//

import Foundation

/*
 Exemplo de resposta da API:
 {
   "success": true,
   "data": {
     "id": "weather-001",
     "temperature": 28.5,
     "feels_like": 30.2,
     "condition": "sunny",
     "humidity": 65,
     "wind_speed": 15.3,
     "location": "São Paulo - SP",
     "last_updated": "2025-01-18T14:30:00Z"
   },
   "timestamp": "2025-01-18T14:30:00Z"
 }
*/

// MARK: - Weather Response DTO

struct WeatherResponseDTO: Codable {
    let success: Bool
    let data: WeatherDataDTO
    let timestamp: String
}

// MARK: - Weather Data DTO

struct WeatherDataDTO: Codable {
    let id: String
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let location: String
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case id
        case temperature
        case feelsLike = "feels_like"
        case condition
        case humidity
        case windSpeed = "wind_speed"
        case location
        case lastUpdated = "last_updated"
    }
}

// MARK: - DTO to Domain Mapping

extension WeatherDataDTO {

    /// Converte DTO para modelo de domínio
    func toDomain() -> Weather? {
        guard let weatherCondition = WeatherCondition(rawValue: condition) else {
            return nil
        }

        let dateFormatter = ISO8601DateFormatter()
        guard let updatedDate = dateFormatter.date(from: lastUpdated) else {
            return nil
        }

        return Weather(
            id: id,
            temperature: temperature,
            feelsLike: feelsLike,
            condition: weatherCondition,
            humidity: humidity,
            windSpeed: windSpeed,
            lastUpdated: updatedDate,
            location: location
        )
    }
}
