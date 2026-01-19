//
//  FetchPOIsUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar pontos de interesse
//

import Foundation
import CoreLocation

/// Caso de uso para buscar POIs da cidade
final class FetchPOIsUseCase {

    // MARK: - Properties

    private let repository: POIsRepositoryProtocol

    // MARK: - Initialization

    init(repository: POIsRepositoryProtocol = POIsRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de todos os POIs
    func execute() async throws -> [PointOfInterest] {
        let pois = try await repository.fetchPOIs()

        // Ordena por tipo e depois por nome
        return pois.sorted { poi1, poi2 in
            if poi1.type == poi2.type {
                return poi1.name < poi2.name
            }
            return poi1.type.description < poi2.type.description
        }
    }

    /// Executa a busca de POIs por tipo
    func execute(type: POIType) async throws -> [PointOfInterest] {
        let pois = try await repository.fetchPOIs(type: type)
        return pois.sorted { $0.name < $1.name }
    }

    /// Executa a busca de POIs próximos
    func executeNearby(from location: CLLocationCoordinate2D, radius: Double = 5000) async throws -> [PointOfInterest] {
        try await repository.fetchNearbyPOIs(from: location, radius: radius)
    }
}
