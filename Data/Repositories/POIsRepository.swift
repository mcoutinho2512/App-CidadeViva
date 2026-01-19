//
//  POIsRepository.swift
//  CidadeViva
//
//  Repositório para dados de pontos de interesse
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation
import CoreLocation

/// Protocolo do repositório de POIs
protocol POIsRepositoryProtocol {
    func fetchPOIs() async throws -> [PointOfInterest]
    func fetchPOIs(type: POIType) async throws -> [PointOfInterest]
    func fetchNearbyPOIs(from location: CLLocationCoordinate2D, radius: Double) async throws -> [PointOfInterest]
}

/// Implementação do repositório de POIs
final class POIsRepository: POIsRepositoryProtocol {

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

    /// Busca todos os POIs
    func fetchPOIs() async throws -> [PointOfInterest] {
        // Tenta buscar do cache primeiro
        if let cachedPOIs: [PointOfInterest] = cacheService.get(forKey: CacheService.CacheKey.pois) {
            #if DEBUG
            print("📍 [POIsRepository] Returning cached POIs data")
            #endif
            return cachedPOIs
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .pois,
            responseType: POIsResponseDTO.self
        )

        let pois = response.results.toDomain()

        // Salva no cache
        cacheService.set(pois, forKey: CacheService.CacheKey.pois)

        return pois
    }

    /// Busca POIs por tipo
    func fetchPOIs(type: POIType) async throws -> [PointOfInterest] {
        let pois = try await fetchPOIs()
        return pois.filter { $0.type == type }
    }

    /// Busca POIs próximos a uma localização
    func fetchNearbyPOIs(from location: CLLocationCoordinate2D, radius: Double) async throws -> [PointOfInterest] {
        let pois = try await fetchPOIs()

        return pois.filter { poi in
            let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = userLocation.distance(from: poiLocation)

            return distance <= radius
        }
        .sorted { poi1, poi2 in
            let location1 = CLLocation(latitude: poi1.coordinate.latitude, longitude: poi1.coordinate.longitude)
            let location2 = CLLocation(latitude: poi2.coordinate.latitude, longitude: poi2.coordinate.longitude)
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

            let distance1 = userLocation.distance(from: location1)
            let distance2 = userLocation.distance(from: location2)

            return distance1 < distance2
        }
    }
}
