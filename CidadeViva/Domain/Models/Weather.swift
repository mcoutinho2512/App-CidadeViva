import Foundation

struct Weather: Identifiable, Equatable {
    let id: UUID
    let temperature: Double
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let location: String
    let updatedAt: Date

    enum WeatherCondition: String, CaseIterable {
        case sunny = "Ensolarado"
        case cloudy = "Nublado"
        case rainy = "Chuvoso"
        case stormy = "Tempestade"
        case partlyCloudy = "Parcialmente Nublado"

        var iconName: String {
            switch self {
            case .sunny: return "sun.max.fill"
            case .cloudy: return "cloud.fill"
            case .rainy: return "cloud.rain.fill"
            case .stormy: return "cloud.bolt.rain.fill"
            case .partlyCloudy: return "cloud.sun.fill"
            }
        }
    }
}
