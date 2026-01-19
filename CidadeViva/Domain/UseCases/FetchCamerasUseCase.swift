import Foundation

protocol FetchCamerasUseCaseProtocol {
    func execute() async throws -> [Camera]
}

final class FetchCamerasUseCase: FetchCamerasUseCaseProtocol {
    private let repository: CamerasRepositoryProtocol

    init(repository: CamerasRepositoryProtocol = CamerasRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Camera] {
        try await repository.fetchCameras()
    }
}
