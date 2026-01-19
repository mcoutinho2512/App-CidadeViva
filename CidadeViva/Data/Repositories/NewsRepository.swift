import Foundation

protocol NewsRepositoryProtocol {
    func fetchNews() async throws -> [News]
}

final class NewsRepository: NewsRepositoryProtocol {
    func fetchNews() async throws -> [News] {
        if AppConfiguration.useFirebase {
            return try await FirestoreService.shared.fetchNews()
        } else {
            return MockData.news
        }
    }
}
