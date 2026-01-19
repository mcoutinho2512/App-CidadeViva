//
//  POIsViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de pontos de interesse
//

import Foundation
import SwiftUI
import CoreLocation

@MainActor
final class POIsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: LoadingState<[PointOfInterest]> = .idle
    @Published var selectedType: POIType?
    @Published var searchText = ""
    @Published var showNearbyOnly = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var nearbyRadius: Double = 5000 // 5km default

    // MARK: - Dependencies

    private let fetchPOIsUseCase: FetchPOIsUseCase

    // MARK: - Computed Properties

    var filteredPOIs: [PointOfInterest] {
        guard case .success(let pois) = state else { return [] }

        var filtered = pois

        // Filter by type
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by nearby if user location is available
        if showNearbyOnly, let location = userLocation {
            let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            filtered = filtered.filter { poi in
                let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
                return userCLLocation.distance(from: poiLocation) <= nearbyRadius
            }
        }

        return filtered
    }

    var poisByType: [POIType: [PointOfInterest]] {
        guard case .success(let pois) = state else { return [:] }
        return Dictionary(grouping: pois, by: { $0.type })
    }

    var nearbyPOIs: [PointOfInterest] {
        guard case .success(let pois) = state,
              let location = userLocation else { return [] }

        let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        return pois
            .map { poi -> (poi: PointOfInterest, distance: Double) in
                let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
                let distance = userCLLocation.distance(from: poiLocation)
                return (poi, distance)
            }
            .filter { $0.distance <= nearbyRadius }
            .sorted { $0.distance < $1.distance }
            .map { $0.poi }
    }

    var topRatedPOIs: [PointOfInterest] {
        guard case .success(let pois) = state else { return [] }
        return pois
            .filter { $0.rating != nil }
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Initialization

    init(fetchPOIsUseCase: FetchPOIsUseCase = FetchPOIsUseCase()) {
        self.fetchPOIsUseCase = fetchPOIsUseCase
    }

    // MARK: - Public Methods

    func loadData() async {
        state = .loading

        do {
            let pois: [PointOfInterest]

            if showNearbyOnly, let location = userLocation {
                pois = try await fetchPOIsUseCase.executeNearby(from: location, radius: nearbyRadius)
            } else if let type = selectedType {
                pois = try await fetchPOIsUseCase.execute(type: type)
            } else {
                pois = try await fetchPOIsUseCase.execute()
            }

            state = .success(pois)
        } catch {
            state = .failure(error)
        }
    }

    func refresh() async {
        await loadData()
    }

    func selectType(_ type: POIType?) {
        selectedType = type
        Task {
            await loadData()
        }
    }

    func toggleNearby() {
        showNearbyOnly.toggle()
        Task {
            await loadData()
        }
    }

    func updateUserLocation(_ location: CLLocationCoordinate2D) {
        userLocation = location
        if showNearbyOnly {
            Task {
                await loadData()
            }
        }
    }

    func updateNearbyRadius(_ radius: Double) {
        nearbyRadius = radius
        if showNearbyOnly {
            Task {
                await loadData()
            }
        }
    }

    func clearFilters() {
        selectedType = nil
        searchText = ""
        showNearbyOnly = false
        Task {
            await loadData()
        }
    }

    func distanceFromUser(to poi: PointOfInterest) -> Double? {
        guard let location = userLocation else { return nil }

        let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)

        return userCLLocation.distance(from: poiLocation)
    }

    func distanceFromUserFormatted(to poi: PointOfInterest) -> String? {
        guard let distance = distanceFromUser(to: poi) else { return nil }

        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
