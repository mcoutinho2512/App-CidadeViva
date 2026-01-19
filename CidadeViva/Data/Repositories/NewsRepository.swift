import Foundation

protocol NewsRepositoryProtocol {
    func fetchNews() async throws -> [News]
}

final class NewsRepository: NewsRepositoryProtocol {
    func fetchNews() async throws -> [News] {
        // TODO: Implement API call
        return MockData.news
    }
}
