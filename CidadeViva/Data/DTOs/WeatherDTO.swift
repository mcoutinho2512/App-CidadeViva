import Foundation

struct WeatherDTO: Codable {
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let location: String
    let updatedAt: String

    func toDomain() -> Weather {
        Weather(
            id: UUID(),
            temperature: temperature,
            condition: Weather.WeatherCondition(rawValue: condition) ?? .partlyCloudy,
            humidity: humidity,
            windSpeed: windSpeed,
            location: location,
            updatedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date()
        )
    }
}
