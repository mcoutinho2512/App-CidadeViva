//
//  NavigationRepository.swift
//  CidadeViva
//
//  Repositório para cálculo de rotas
//  Responsável por buscar rotas da API
//

import Foundation
import CoreLocation

/// Protocolo do repositório de navegação
protocol NavigationRepositoryProtocol {
    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        mode: RouteMode
    ) async throws -> Route
}

/// Implementação do repositório de navegação
final class NavigationRepository: NavigationRepositoryProtocol {

    // MARK: - Properties

    private let apiClient: APIClient

    // MARK: - Initialization

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Calcula rota entre dois pontos
    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        mode: RouteMode
    ) async throws -> Route {

        // TODO: Quando conectar à API Django real, fazer POST para /api/v1/navigation/route/
        // Por enquanto, retorna rota mockada

        #if DEBUG
        print("🗺️ [NavigationRepository] Calculating route from \(origin) to \(destination)")
        #endif

        // Simula delay de rede
        try await Task.sleep(nanoseconds: 500_000_000) // 500ms

        // Cria rota mockada simples
        let routeId = UUID().uuidString
        let distance = calculateDistance(from: origin, to: destination)
        let duration = estimateDuration(distance: distance, mode: mode)

        let originPoint = RoutePoint(
            name: "Localização Atual",
            address: nil,
            coordinate: origin
        )

        let destinationPoint = RoutePoint(
            name: "Destino",
            address: nil,
            coordinate: destination
        )

        // Coordenadas simplificadas (linha reta)
        let coordinates = [origin, destination]

        // Instruções básicas
        let instructions = [
            RouteInstruction(
                id: "inst-1",
                text: "Siga em direção ao destino",
                distance: distance,
                duration: duration,
                coordinate: origin,
                type: .start
            ),
            RouteInstruction(
                id: "inst-2",
                text: "Você chegou ao destino",
                distance: 0,
                duration: 0,
                coordinate: destination,
                type: .arrive
            )
        ]

        return Route(
            id: routeId,
            origin: originPoint,
            destination: destinationPoint,
            mode: mode,
            distance: distance,
            duration: duration,
            coordinates: coordinates,
            instructions: instructions,
            createdAt: Date()
        )
    }

    // MARK: - Private Methods

    /// Calcula distância entre dois pontos (em metros)
    private func calculateDistance(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

        return originLocation.distance(from: destinationLocation)
    }

    /// Estima duração baseada na distância e modo de transporte
    private func estimateDuration(distance: Double, mode: RouteMode) -> Double {
        let speedKmH: Double

        switch mode {
        case .walking:
            speedKmH = 5.0 // 5 km/h
        case .cycling:
            speedKmH = 15.0 // 15 km/h
        case .driving:
            speedKmH = 40.0 // 40 km/h (média urbana)
        }

        let distanceKm = distance / 1000
        let hours = distanceKm / speedKmH
        let seconds = hours * 3600

        return seconds
    }
}
