//
//  NavigationViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de navegação/rotas
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

@MainActor
final class NavigationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var routeState: LoadingState<Route> = .idle
    @Published var selectedMode: RouteMode = .walking
    @Published var origin: CLLocationCoordinate2D?
    @Published var destination: CLLocationCoordinate2D?
    @Published var selectedPOI: PointOfInterest?
    @Published var mapRegion: MKCoordinateRegion
    @Published var showRouteInstructions = false

    // MARK: - Dependencies

    private let calculateRouteUseCase: CalculateRouteUseCase
    private let fetchPOIsUseCase: FetchPOIsUseCase

    // MARK: - Computed Properties

    var currentRoute: Route? {
        if case .success(let route) = routeState {
            return route
        }
        return nil
    }

    var hasValidOriginAndDestination: Bool {
        origin != nil && destination != nil
    }

    var canCalculateRoute: Bool {
        hasValidOriginAndDestination && routeState != .loading
    }

    var routeDistanceFormatted: String? {
        guard let route = currentRoute else { return nil }
        return route.distanceFormatted
    }

    var routeDurationFormatted: String? {
        guard let route = currentRoute else { return nil }
        return route.durationFormatted
    }

    // MARK: - Initialization

    init(
        calculateRouteUseCase: CalculateRouteUseCase = CalculateRouteUseCase(),
        fetchPOIsUseCase: FetchPOIsUseCase = FetchPOIsUseCase()
    ) {
        self.calculateRouteUseCase = calculateRouteUseCase
        self.fetchPOIsUseCase = fetchPOIsUseCase

        // Default region (can be updated based on user location)
        self.mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), // São Paulo
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    // MARK: - Public Methods

    func calculateRoute() async {
        guard let origin = origin, let destination = destination else {
            routeState = .failure(NSError(domain: "NavigationError", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Origem e destino são obrigatórios"
            ]))
            return
        }

        routeState = .loading

        do {
            let route = try await calculateRouteUseCase.execute(
                from: origin,
                to: destination,
                mode: selectedMode
            )
            routeState = .success(route)

            // Update map region to show the route
            updateMapRegionForRoute(route)
        } catch {
            routeState = .failure(error)
        }
    }

    func setOrigin(_ coordinate: CLLocationCoordinate2D) {
        origin = coordinate
        updateMapRegion()
    }

    func setDestination(_ coordinate: CLLocationCoordinate2D) {
        destination = coordinate
        updateMapRegion()
    }

    func setDestination(poi: PointOfInterest) {
        selectedPOI = poi
        destination = poi.coordinate
        updateMapRegion()
    }

    func setMode(_ mode: RouteMode) {
        selectedMode = mode
        // Recalculate route if we already have one
        if currentRoute != nil {
            Task {
                await calculateRoute()
            }
        }
    }

    func swapOriginAndDestination() {
        let temp = origin
        origin = destination
        destination = temp

        // Recalculate route if we already have one
        if currentRoute != nil {
            Task {
                await calculateRoute()
            }
        }
    }

    func clearRoute() {
        routeState = .idle
        origin = nil
        destination = nil
        selectedPOI = nil
        showRouteInstructions = false
    }

    func toggleRouteInstructions() {
        showRouteInstructions.toggle()
    }

    // MARK: - Private Methods

    private func updateMapRegion() {
        var coordinates: [CLLocationCoordinate2D] = []

        if let origin = origin {
            coordinates.append(origin)
        }
        if let destination = destination {
            coordinates.append(destination)
        }

        guard !coordinates.isEmpty else { return }

        if coordinates.count == 1 {
            mapRegion = MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        } else {
            // Calculate region that fits both points
            let minLat = coordinates.map { $0.latitude }.min() ?? 0
            let maxLat = coordinates.map { $0.latitude }.max() ?? 0
            let minLon = coordinates.map { $0.longitude }.min() ?? 0
            let maxLon = coordinates.map { $0.longitude }.max() ?? 0

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )

            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5,
                longitudeDelta: (maxLon - minLon) * 1.5
            )

            mapRegion = MKCoordinateRegion(center: center, span: span)
        }
    }

    private func updateMapRegionForRoute(_ route: Route) {
        let coordinates = route.coordinates

        guard !coordinates.isEmpty else { return }

        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )

        mapRegion = MKCoordinateRegion(center: center, span: span)
    }
}
