//
//  FetchEventsUseCase.swift
//  CidadeViva
//
//  Caso de uso para buscar eventos
//

import Foundation

/// Caso de uso para buscar eventos da cidade
final class FetchEventsUseCase {

    // MARK: - Properties

    private let repository: EventsRepositoryProtocol

    // MARK: - Initialization

    init(repository: EventsRepositoryProtocol = EventsRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Executa a busca de todos os eventos
    func execute() async throws -> [Event] {
        try await repository.fetchEvents()
    }

    /// Executa a busca de eventos futuros
    func executeUpcoming() async throws -> [Event] {
        try await repository.fetchUpcomingEvents()
    }

    /// Executa a busca de eventos em destaque
    func executeFeatured() async throws -> [Event] {
        try await repository.fetchFeaturedEvents()
    }

    /// Executa a busca de eventos por categoria
    func execute(category: EventCategory) async throws -> [Event] {
        try await repository.fetchEvents(category: category)
    }
}
