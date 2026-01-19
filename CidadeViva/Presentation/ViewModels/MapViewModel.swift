import Foundation
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.1195, longitude: -34.8450),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var pointsOfInterest: [PointOfInterest] = []
    @Published var cameras: [Camera] = []
    @Published var selectedPOI: PointOfInterest?
    @Published var selectedCategory: PointOfInterest.Category?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchPOIsUseCase: FetchPOIsUseCaseProtocol
    private let fetchCamerasUseCase: FetchCamerasUseCaseProtocol

    init(
        fetchPOIsUseCase: FetchPOIsUseCaseProtocol = FetchPOIsUseCase(),
        fetchCamerasUseCase: FetchCamerasUseCaseProtocol = FetchCamerasUseCase()
    ) {
        self.fetchPOIsUseCase = fetchPOIsUseCase
        self.fetchCamerasUseCase = fetchCamerasUseCase
    }

    func loadData() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadPOIs() }
            group.addTask { await self.loadCameras() }
        }

        isLoading = false
    }

    private func loadPOIs() async {
        do {
            if let category = selectedCategory {
                pointsOfInterest = try await fetchPOIsUseCase.execute(category: category)
            } else {
                pointsOfInterest = try await fetchPOIsUseCase.execute()
            }
        } catch {
            self.error = error
        }
    }

    private func loadCameras() async {
        do {
            cameras = try await fetchCamerasUseCase.execute()
        } catch {
            self.error = error
        }
    }

    func centerOnUserLocation() {
        if let location = LocationService.shared.getCurrentLocation() {
            region.center = location.coordinate
        }
    }

    func filterByCategory(_ category: PointOfInterest.Category?) {
        selectedCategory = category
        Task {
            await loadPOIs()
        }
    }
}
