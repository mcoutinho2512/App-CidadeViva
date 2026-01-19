import Foundation

protocol FetchNewsUseCaseProtocol {
    func execute() async throws -> [News]
}

final class FetchNewsUseCase: FetchNewsUseCaseProtocol {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol = NewsRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [News] {
        try await repository.fetchNews()
    }
}
