//
//  NewsRepository.swift
//  CidadeViva
//
//  Repositório para dados de notícias
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation

/// Protocolo do repositório de notícias
protocol NewsRepositoryProtocol {
    func fetchNews() async throws -> [News]
    func fetchFeaturedNews() async throws -> [News]
    func fetchNews(category: String) async throws -> [News]
}

/// Implementação do repositório de notícias
final class NewsRepository: NewsRepositoryProtocol {

    // MARK: - Properties

    private let apiClient: APIClient
    private let cacheService: CacheService

    // MARK: - Initialization

    init(
        apiClient: APIClient = APIClient(),
        cacheService: CacheService = .shared
    ) {
        self.apiClient = apiClient
        self.cacheService = cacheService
    }

    // MARK: - Public Methods

    /// Busca todas as notícias
    func fetchNews() async throws -> [News] {
        // Tenta buscar do cache primeiro
        if let cachedNews: [News] = cacheService.get(forKey: CacheService.CacheKey.news) {
            #if DEBUG
            print("📰 [NewsRepository] Returning cached news data")
            #endif
            return cachedNews
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .news,
            responseType: NewsResponseDTO.self
        )

        let news = response.results.toDomain()
            .filter { !$0.isExpired }
            .sorted { $0.publishedAt > $1.publishedAt }

        // Salva no cache
        cacheService.set(news, forKey: CacheService.CacheKey.news)

        return news
    }

    /// Busca notícias em destaque
    func fetchFeaturedNews() async throws -> [News] {
        let news = try await fetchNews()
        return news.filter { $0.isFeatured }
    }

    /// Busca notícias por categoria
    func fetchNews(category: String) async throws -> [News] {
        let news = try await fetchNews()
        return news.filter { $0.category?.lowercased() == category.lowercased() }
    }
}
