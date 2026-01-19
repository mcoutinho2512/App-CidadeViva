import Foundation

protocol AlertsRepositoryProtocol {
    func fetchAlerts() async throws -> [Alert]
}

final class AlertsRepository: AlertsRepositoryProtocol {
    func fetchAlerts() async throws -> [Alert] {
        // TODO: Implement API call
        return MockData.alerts
    }
}
