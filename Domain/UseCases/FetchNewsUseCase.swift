//
//  FetchNewsUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar notícias
//

import Foundation

/// Caso de uso para buscar notícias da cidade
final class FetchNewsUseCase {

    // MARK: - Properties

    private let repository: NewsRepositoryProtocol

    // MARK: - Initialization

    init(repository: NewsRepositoryProtocol = NewsRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de todas as notícias
    func execute() async throws -> [News] {
        try await repository.fetchNews()
    }

    /// Executa a busca de notícias em destaque
    func executeFeatured() async throws -> [News] {
        try await repository.fetchFeaturedNews()
    }

    /// Executa a busca de notícias por categoria
    func execute(category: String) async throws -> [News] {
        try await repository.fetchNews(category: category)
    }
}
