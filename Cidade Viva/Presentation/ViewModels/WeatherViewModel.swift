//
//  WeatherViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de Clima
//

import Foundation
import Combine

/// ViewModel da tela de Clima
@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var weather: Weather?
    @Published var loadingState: LoadingState = .idle

    // MARK: - Properties

    private let fetchWeatherUseCase: FetchWeatherUseCase

    // MARK: - Computed Properties

    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .error(let error) = loadingState {
            return error.localizedDescription
        }
        return nil
    }

    // MARK: - Initialization

    init(fetchWeatherUseCase: FetchWeatherUseCase = FetchWeatherUseCase()) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
    }

    // MARK: - Public Methods

    /// Carrega dados climáticos
    func loadWeather() async {
        loadingState = .loading

        do {
            let fetchedWeather = try await fetchWeatherUseCase.execute()
            self.weather = fetchedWeather
            self.loadingState = .success
        } catch {
            self.loadingState = .error(error)
        }
    }

    /// Atualiza os dados (pull to refresh)
    func refresh() async {
        CacheService.shared.remove(forKey: CacheService.CacheKey.weather)
        await loadWeather()
    }
}
