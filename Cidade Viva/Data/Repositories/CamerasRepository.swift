//
//  CamerasRepository.swift
//  CidadeViva
//
//  Repositório para dados de câmeras
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation

/// Protocolo do repositório de câmeras
protocol CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera]
}

/// Implementação do repositório de câmeras
final class CamerasRepository: CamerasRepositoryProtocol {

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

    /// Busca lista de câmeras
    func fetchCameras() async throws -> [Camera] {
        // Tenta buscar do cache primeiro
        if let cachedCameras: [Camera] = cacheService.get(forKey: CacheService.CacheKey.cameras) {
            #if DEBUG
            print("📹 [CamerasRepository] Returning cached cameras data")
            #endif
            return cachedCameras
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .cameras,
            responseType: CamerasResponseDTO.self
        )

        let cameras = response.data.toDomain()

        // Salva no cache
        cacheService.set(cameras, forKey: CacheService.CacheKey.cameras)

        return cameras
    }
}
