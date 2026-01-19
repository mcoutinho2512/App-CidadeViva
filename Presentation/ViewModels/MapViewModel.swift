//
//  MapViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de Mapa
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

/// ViewModel da tela de Mapa
@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var cameras: [Camera] = []
    @Published var alerts: [Alert] = []
    @Published var loadingState: LoadingState = .idle
    @Published var region: MKCoordinateRegion
    @Published var selectedCamera: Camera?
    @Published var selectedAlert: Alert?
    @Published var showCameras: Bool = true
    @Published var showAlerts: Bool = true

    // MARK: - Properties

    private let fetchCamerasUseCase: FetchCamerasUseCase
    private let fetchAlertsUseCase: FetchAlertsUseCase
    private let locationService: LocationService

    // MARK: - Computed Properties

    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .error(let error) = loadingState {
            return error.localizedDescription
        }
        return nil
    }

    var visibleCameras: [Camera] {
        showCameras ? cameras : []
    }

    var visibleAlerts: [Alert] {
        showAlerts ? alerts.filter { $0.isActive && !$0.isExpired } : []
    }

    // MARK: - Initialization

    init(
        fetchCamerasUseCase: FetchCamerasUseCase = FetchCamerasUseCase(),
        fetchAlertsUseCase: FetchAlertsUseCase = FetchAlertsUseCase(),
        locationService: LocationService = LocationService()
    ) {
        self.fetchCamerasUseCase = fetchCamerasUseCase
        self.fetchAlertsUseCase = fetchAlertsUseCase
        self.locationService = locationService

        // Região padrão (São Paulo)
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: AppConfiguration.Map.defaultLatitude,
                longitude: AppConfiguration.Map.defaultLongitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: AppConfiguration.Map.defaultZoomLevel,
                longitudeDelta: AppConfiguration.Map.defaultZoomLevel
            )
        )
    }

    // MARK: - Public Methods

    /// Carrega dados para o mapa
    func loadMapData() async {
        loadingState = .loading

        do {
            // Carrega dados em paralelo
            async let camerasTask = fetchCamerasUseCase.execute()
            async let alertsTask = fetchAlertsUseCase.executeActiveOnly()

            let (fetchedCameras, fetchedAlerts) = try await (camerasTask, alertsTask)

            self.cameras = fetchedCameras
            self.alerts = fetchedAlerts
            self.loadingState = .success

        } catch {
            self.loadingState = .error(error)
        }
    }

    /// Atualiza os dados (pull to refresh)
    func refresh() async {
        CacheService.shared.remove(forKey: CacheService.CacheKey.cameras)
        CacheService.shared.remove(forKey: CacheService.CacheKey.alerts)
        await loadMapData()
    }

    /// Centraliza o mapa em uma câmera
    func centerOnCamera(_ camera: Camera) {
        selectedCamera = camera
        selectedAlert = nil
        withAnimation {
            region.center = camera.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }

    /// Centraliza o mapa em um alerta
    func centerOnAlert(_ alert: Alert) {
        guard let coordinate = alert.coordinate else { return }
        selectedAlert = alert
        selectedCamera = nil
        withAnimation {
            region.center = coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }

    /// Centraliza o mapa na localização do usuário
    func centerOnUserLocation() {
        guard let userLocation = locationService.userLocation else {
            locationService.requestCurrentLocation()
            return
        }

        withAnimation {
            region.center = userLocation
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }

    /// Alterna visibilidade das câmeras
    func toggleCamerasVisibility() {
        showCameras.toggle()
    }

    /// Alterna visibilidade dos alertas
    func toggleAlertsVisibility() {
        showAlerts.toggle()
    }

    /// Solicita permissão de localização
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
}
