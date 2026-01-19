//
//  HomeViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela Home
//

import Foundation

/// Estados possíveis da tela
enum LoadingState {
    case idle
    case loading
    case success
    case error(Error)
}

/// ViewModel da tela Home
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var weather: Weather?
    @Published var camerasCount: Int = 0
    @Published var activeAlertsCount: Int = 0
    @Published var loadingState: LoadingState = .idle
    @Published var lastUpdated: Date?

    // MARK: - Properties

    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let fetchCamerasUseCase: FetchCamerasUseCase
    private let fetchAlertsUseCase: FetchAlertsUseCase

    // MARK: - Computed Properties

    var lastUpdatedText: String {
        guard let lastUpdated = lastUpdated else {
            return "Nunca atualizado"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        return "Atualizado \(formatter.localizedString(for: lastUpdated, relativeTo: Date()))"
    }

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

    init(
        fetchWeatherUseCase: FetchWeatherUseCase = FetchWeatherUseCase(),
        fetchCamerasUseCase: FetchCamerasUseCase = FetchCamerasUseCase(),
        fetchAlertsUseCase: FetchAlertsUseCase = FetchAlertsUseCase()
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.fetchCamerasUseCase = fetchCamerasUseCase
        self.fetchAlertsUseCase = fetchAlertsUseCase
    }

    // MARK: - Public Methods

    /// Carrega todos os dados da tela
    func loadData() async {
        loadingState = .loading

        do {
            // Carrega dados em paralelo
            async let weatherTask = fetchWeatherUseCase.execute()
            async let camerasTask = fetchCamerasUseCase.execute()
            async let alertsTask = fetchAlertsUseCase.executeActiveOnly()

            let (fetchedWeather, cameras, alerts) = try await (weatherTask, camerasTask, alertsTask)

            self.weather = fetchedWeather
            self.camerasCount = cameras.count
            self.activeAlertsCount = alerts.count
            self.lastUpdated = Date()
            self.loadingState = .success

        } catch {
            self.loadingState = .error(error)
        }
    }

    /// Atualiza os dados (pull to refresh)
    func refresh() async {
        // Limpa cache antes de recarregar
        CacheService.shared.clearAll()
        await loadData()
    }
}
