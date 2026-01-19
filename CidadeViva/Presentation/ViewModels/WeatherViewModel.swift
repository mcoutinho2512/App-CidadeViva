import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol

    init(fetchWeatherUseCase: FetchWeatherUseCaseProtocol = FetchWeatherUseCase()) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
    }

    func loadWeather() async {
        isLoading = true
        error = nil

        do {
            weather = try await fetchWeatherUseCase.execute()
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
