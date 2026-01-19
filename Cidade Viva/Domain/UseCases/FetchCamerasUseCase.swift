//
//  FetchCamerasUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar dados de câmeras
//

import Foundation

/// Caso de uso para buscar lista de câmeras
final class FetchCamerasUseCase {

    // MARK: - Properties

    private let repository: CamerasRepositoryProtocol

    // MARK: - Initialization

    init(repository: CamerasRepositoryProtocol = CamerasRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de câmeras
    func execute() async throws -> [Camera] {
        let cameras = try await repository.fetchCameras()

        // Ordena por região e depois por nome
        return cameras.sorted { camera1, camera2 in
            if camera1.region == camera2.region {
                return camera1.name < camera2.name
            }
            return camera1.region < camera2.region
        }
    }

    /// Executa a busca de câmeras filtradas por região
    func execute(region: CityRegion) async throws -> [Camera] {
        let cameras = try await execute()

        if region == .all {
            return cameras
        }

        return cameras.filter { $0.region == region.rawValue }
    }

    /// Executa a busca de câmeras filtradas por status
    func execute(status: CameraStatus) async throws -> [Camera] {
        let cameras = try await execute()
        return cameras.filter { $0.status == status }
    }
}
