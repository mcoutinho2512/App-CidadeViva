import Foundation

protocol FetchAlertsUseCaseProtocol {
    func execute() async throws -> [Alert]
}

final class FetchAlertsUseCase: FetchAlertsUseCaseProtocol {
    private let repository: AlertsRepositoryProtocol

    init(repository: AlertsRepositoryProtocol = AlertsRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Alert] {
        try await repository.fetchAlerts()
    }
}
