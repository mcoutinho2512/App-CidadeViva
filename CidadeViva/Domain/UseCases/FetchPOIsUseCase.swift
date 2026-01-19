import Foundation

protocol FetchPOIsUseCaseProtocol {
    func execute() async throws -> [PointOfInterest]
    func execute(category: PointOfInterest.Category) async throws -> [PointOfInterest]
}

final class FetchPOIsUseCase: FetchPOIsUseCaseProtocol {
    private let repository: POIsRepositoryProtocol

    init(repository: POIsRepositoryProtocol = POIsRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [PointOfInterest] {
        try await repository.fetchPOIs()
    }

    func execute(category: PointOfInterest.Category) async throws -> [PointOfInterest] {
        try await repository.fetchPOIs(by: category)
    }
}
