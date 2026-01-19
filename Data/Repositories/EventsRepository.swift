//
//  EventsRepository.swift
//  CidadeViva
//
//  Repositório para dados de eventos
//  Responsável por buscar dados da API e gerenciar cache
//

import Foundation

/// Protocolo do repositório de eventos
protocol EventsRepositoryProtocol {
    func fetchEvents() async throws -> [Event]
    func fetchUpcomingEvents() async throws -> [Event]
    func fetchFeaturedEvents() async throws -> [Event]
    func fetchEvents(category: EventCategory) async throws -> [Event]
}

/// Implementação do repositório de eventos
final class EventsRepository: EventsRepositoryProtocol {

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

    /// Busca todos os eventos
    func fetchEvents() async throws -> [Event] {
        // Tenta buscar do cache primeiro
        if let cachedEvents: [Event] = cacheService.get(forKey: CacheService.CacheKey.events) {
            #if DEBUG
            print("📅 [EventsRepository] Returning cached events data")
            #endif
            return cachedEvents
        }

        // Busca da API
        let response = try await apiClient.request(
            endpoint: .events,
            responseType: EventsResponseDTO.self
        )

        let events = response.results.toDomain()

        // Salva no cache
        cacheService.set(events, forKey: CacheService.CacheKey.events)

        return events
    }

    /// Busca eventos futuros (upcoming)
    func fetchUpcomingEvents() async throws -> [Event] {
        let events = try await fetchEvents()
        let now = Date()

        return events
            .filter { !$0.isPast }
            .sorted { $0.startDate < $1.startDate }
    }

    /// Busca eventos em destaque
    func fetchFeaturedEvents() async throws -> [Event] {
        let events = try await fetchEvents()
        return events.filter { $0.isFeatured }
    }

    /// Busca eventos por categoria
    func fetchEvents(category: EventCategory) async throws -> [Event] {
        let events = try await fetchEvents()
        return events.filter { $0.category == category }
    }
}
