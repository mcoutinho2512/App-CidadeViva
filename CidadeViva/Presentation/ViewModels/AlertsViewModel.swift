import Foundation

@MainActor
final class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var selectedSeverity: Alert.Severity?
    @Published var selectedCategory: Alert.Category?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchAlertsUseCase: FetchAlertsUseCaseProtocol

    init(fetchAlertsUseCase: FetchAlertsUseCaseProtocol = FetchAlertsUseCase()) {
        self.fetchAlertsUseCase = fetchAlertsUseCase
    }

    func loadAlerts() async {
        isLoading = true
        error = nil

        do {
            alerts = try await fetchAlertsUseCase.execute()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var filteredAlerts: [Alert] {
        var result = alerts

        if let severity = selectedSeverity {
            result = result.filter { $0.severity == severity }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        return result.sorted { $0.createdAt > $1.createdAt }
    }

    var criticalAlerts: [Alert] {
        alerts.filter { $0.severity == .critical || $0.severity == .high }
    }
}
