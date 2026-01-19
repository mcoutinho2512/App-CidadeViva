import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    @Published var news: [News] = []
    @Published var selectedCategory: News.Category?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchNewsUseCase: FetchNewsUseCaseProtocol

    init(fetchNewsUseCase: FetchNewsUseCaseProtocol = FetchNewsUseCase()) {
        self.fetchNewsUseCase = fetchNewsUseCase
    }

    func loadNews() async {
        isLoading = true
        error = nil

        do {
            news = try await fetchNewsUseCase.execute()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var filteredNews: [News] {
        guard let category = selectedCategory else {
            return news.sorted { $0.publishedAt > $1.publishedAt }
        }
        return news.filter { $0.category == category }.sorted { $0.publishedAt > $1.publishedAt }
    }

    var latestNews: [News] {
        Array(news.sorted { $0.publishedAt > $1.publishedAt }.prefix(5))
    }
}
