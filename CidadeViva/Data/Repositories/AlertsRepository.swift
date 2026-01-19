import Foundation

protocol AlertsRepositoryProtocol {
    func fetchAlerts() async throws -> [Alert]
}

final class AlertsRepository: AlertsRepositoryProtocol {
    func fetchAlerts() async throws -> [Alert] {
        if AppConfiguration.useFirebase {
            return try await FirestoreService.shared.fetchAlerts()
        } else {
            return MockData.alerts
        }
    }
}
