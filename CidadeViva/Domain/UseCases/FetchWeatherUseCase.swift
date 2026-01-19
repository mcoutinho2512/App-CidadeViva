import Foundation

protocol FetchWeatherUseCaseProtocol {
    func execute() async throws -> Weather
}

final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }

    func execute() async throws -> Weather {
        try await repository.fetchCurrentWeather()
    }
}
