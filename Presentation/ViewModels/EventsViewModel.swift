//
//  EventsViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de eventos
//

import Foundation
import SwiftUI

@MainActor
final class EventsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: LoadingState<[Event]> = .idle
    @Published var selectedCategory: EventCategory?
    @Published var searchText = ""
    @Published var showFeaturedOnly = false
    @Published var showUpcomingOnly = true

    // MARK: - Dependencies

    private let fetchEventsUseCase: FetchEventsUseCase

    // MARK: - Computed Properties

    var filteredEvents: [Event] {
        guard case .success(let events) = state else { return [] }

        var filtered = events

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by featured
        if showFeaturedOnly {
            filtered = filtered.filter { $0.isFeatured }
        }

        // Filter by upcoming (not past)
        if showUpcomingOnly {
            filtered = filtered.filter { !$0.isPast }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort by start date
        return filtered.sorted { $0.startDate < $1.startDate }
    }

    var featuredEvents: [Event] {
        guard case .success(let events) = state else { return [] }
        return events.filter { $0.isFeatured && !$0.isPast }
            .sorted { $0.startDate < $1.startDate }
            .prefix(3)
            .map { $0 }
    }

    var upcomingEvents: [Event] {
        guard case .success(let events) = state else { return [] }
        return events.filter { !$0.isPast }
            .sorted { $0.startDate < $1.startDate }
    }

    var eventsByCategory: [EventCategory: [Event]] {
        guard case .success(let events) = state else { return [:] }
        return Dictionary(grouping: events.filter { !$0.isPast }, by: { $0.category })
    }

    // MARK: - Initialization

    init(fetchEventsUseCase: FetchEventsUseCase = FetchEventsUseCase()) {
        self.fetchEventsUseCase = fetchEventsUseCase
    }

    // MARK: - Public Methods

    func loadData() async {
        state = .loading

        do {
            let events: [Event]

            if showUpcomingOnly {
                events = try await fetchEventsUseCase.executeUpcoming()
            } else if showFeaturedOnly {
                events = try await fetchEventsUseCase.executeFeatured()
            } else if let category = selectedCategory {
                events = try await fetchEventsUseCase.execute(category: category)
            } else {
                events = try await fetchEventsUseCase.execute()
            }

            state = .success(events)
        } catch {
            state = .failure(error)
        }
    }

    func refresh() async {
        await loadData()
    }

    func selectCategory(_ category: EventCategory?) {
        selectedCategory = category
        Task {
            await loadData()
        }
    }

    func toggleFeatured() {
        showFeaturedOnly.toggle()
        Task {
            await loadData()
        }
    }

    func toggleUpcoming() {
        showUpcomingOnly.toggle()
        Task {
            await loadData()
        }
    }

    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        showFeaturedOnly = false
        showUpcomingOnly = true
        Task {
            await loadData()
        }
    }
}
