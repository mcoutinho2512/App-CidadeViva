//
//  FetchAlertsUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar dados de alertas
//

import Foundation

/// Caso de uso para buscar lista de alertas
final class FetchAlertsUseCase {

    // MARK: - Properties

    private let repository: AlertsRepositoryProtocol

    // MARK: - Initialization

    init(repository: AlertsRepositoryProtocol = AlertsRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de alertas
    func execute() async throws -> [Alert] {
        let alerts = try await repository.fetchAlerts()

        // Ordena por severidade (maior para menor) e depois por data (mais recente primeiro)
        return alerts.sorted { alert1, alert2 in
            if alert1.severity.priority == alert2.severity.priority {
                return alert1.createdAt > alert2.createdAt
            }
            return alert1.severity.priority > alert2.severity.priority
        }
    }

    /// Executa a busca apenas de alertas ativos
    func executeActiveOnly() async throws -> [Alert] {
        let alerts = try await execute()
        return alerts.filter { $0.isActive && !$0.isExpired }
    }

    /// Executa a busca de alertas filtrados por tipo
    func execute(type: AlertType) async throws -> [Alert] {
        let alerts = try await execute()
        return alerts.filter { $0.type == type }
    }

    /// Executa a busca de alertas filtrados por severidade mínima
    func execute(minimumSeverity: AlertSeverity) async throws -> [Alert] {
        let alerts = try await execute()
        return alerts.filter { $0.severity.priority >= minimumSeverity.priority }
    }
}
