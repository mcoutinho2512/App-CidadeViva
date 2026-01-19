import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var alerts: [Alert] = []
    @Published var news: [News] = []
    @Published var events: [Event] = []
    @Published var cameras: [Camera] = []
    @Published var pointsOfInterest: [PointOfInterest] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
    private let fetchAlertsUseCase: FetchAlertsUseCaseProtocol
    private let fetchNewsUseCase: FetchNewsUseCaseProtocol
    private let fetchEventsUseCase: FetchEventsUseCaseProtocol

    init(
        fetchWeatherUseCase: FetchWeatherUseCaseProtocol = FetchWeatherUseCase(),
        fetchAlertsUseCase: FetchAlertsUseCaseProtocol = FetchAlertsUseCase(),
        fetchNewsUseCase: FetchNewsUseCaseProtocol = FetchNewsUseCase(),
        fetchEventsUseCase: FetchEventsUseCaseProtocol = FetchEventsUseCase()
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.fetchAlertsUseCase = fetchAlertsUseCase
        self.fetchNewsUseCase = fetchNewsUseCase
        self.fetchEventsUseCase = fetchEventsUseCase
    }

    func loadData() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWeather() }
            group.addTask { await self.loadAlerts() }
            group.addTask { await self.loadNews() }
            group.addTask { await self.loadEvents() }
            group.addTask { await self.loadCameras() }
            group.addTask { await self.loadPOIs() }
        }

        isLoading = false
    }

    private func loadWeather() async {
        do {
            weather = try await fetchWeatherUseCase.execute()
        } catch {
            self.error = error
        }
    }

    private func loadAlerts() async {
        do {
            alerts = try await fetchAlertsUseCase.execute()
        } catch {
            self.error = error
        }
    }

    private func loadNews() async {
        do {
            news = try await fetchNewsUseCase.execute()
        } catch {
            self.error = error
        }
    }

    private func loadEvents() async {
        do {
            events = try await fetchEventsUseCase.execute()
        } catch {
            self.error = error
        }
    }

    private func loadCameras() async {
        // Usando dados mock por enquanto
        cameras = MockData.cameras
    }

    private func loadPOIs() async {
        // Usando dados mock por enquanto
        pointsOfInterest = MockData.pointsOfInterest
    }
}
