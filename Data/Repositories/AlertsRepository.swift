//
//  AlertsRepository.swift
//  CidadeViva
//
//  Repositório para dados de alertas
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation

/// Protocolo do repositório de alertas
protocol AlertsRepositoryProtocol {
    func fetchAlerts() async throws -> [Alert]
}

/// Implementação do repositório de alertas
final class AlertsRepository: AlertsRepositoryProtocol {

    // MARK: - Properties

    private let apiClient: APIClient
    private let cacheService: CacheService

    // MARK: - Initialization

    init(
        apiClient: APIClient = APIClient(),
        cacheService: CacheService = .shared
    ) {
        self.apiClient = apiClient
        self.cacheService = cacheService
    }

    // MARK: - Public Methods

    /// Busca lista de alertas
    func fetchAlerts() async throws -> [Alert] {
        // Tenta buscar do cache primeiro
        if let cachedAlerts: [Alert] = cacheService.get(forKey: CacheService.CacheKey.alerts) {
            #if DEBUG
            print("⚠️ [AlertsRepository] Returning cached alerts data")
            #endif
            return cachedAlerts
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .alerts,
            responseType: AlertsResponseDTO.self
        )

        let alerts = response.data.toDomain()

        // Salva no cache
        cacheService.set(alerts, forKey: CacheService.CacheKey.alerts)

        return alerts
    }
}
