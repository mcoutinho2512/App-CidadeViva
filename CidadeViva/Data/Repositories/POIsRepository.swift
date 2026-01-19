import Foundation

protocol POIsRepositoryProtocol {
    func fetchPOIs() async throws -> [PointOfInterest]
    func fetchPOIs(by category: PointOfInterest.Category) async throws -> [PointOfInterest]
}

final class POIsRepository: POIsRepositoryProtocol {
    func fetchPOIs() async throws -> [PointOfInterest] {
        // TODO: Implement API call
        return MockData.pointsOfInterest
    }

    func fetchPOIs(by category: PointOfInterest.Category) async throws -> [PointOfInterest] {
        let allPOIs = try await fetchPOIs()
        return allPOIs.filter { $0.category == category }
    }
}
