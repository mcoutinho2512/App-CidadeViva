import Foundation

protocol WeatherRepositoryProtocol {
    func fetchCurrentWeather() async throws -> Weather
}

final class WeatherRepository: WeatherRepositoryProtocol {
    func fetchCurrentWeather() async throws -> Weather {
        // TODO: Implement API call
        // For now, return mock data
        return MockData.weather
    }
}
