//
//  NewsViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de notícias
//

import Foundation
import SwiftUI

@MainActor
final class NewsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: LoadingState<[News]> = .idle
    @Published var selectedCategory: String?
    @Published var searchText = ""
    @Published var showFeaturedOnly = false

    // MARK: - Dependencies

    private let fetchNewsUseCase: FetchNewsUseCase

    // MARK: - Computed Properties

    var filteredNews: [News] {
        guard case .success(let news) = state else { return [] }

        var filtered = news

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by featured
        if showFeaturedOnly {
            filtered = filtered.filter { $0.isFeatured }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summary.localizedCaseInsensitiveContains(searchText) ||
                ($0.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // Sort by published date (newest first)
        return filtered.sorted { $0.publishedAt > $1.publishedAt }
    }

    var featuredNews: [News] {
        guard case .success(let news) = state else { return [] }
        return news.filter { $0.isFeatured && !$0.isExpired }
            .sorted { $0.publishedAt > $1.publishedAt }
            .prefix(3)
            .map { $0 }
    }

    var recentNews: [News] {
        guard case .success(let news) = state else { return [] }
        return news.filter { $0.isRecent && !$0.isExpired }
            .sorted { $0.publishedAt > $1.publishedAt }
    }

    var newsByCategory: [String: [News]] {
        guard case .success(let news) = state else { return [:] }
        let categorizedNews = news.compactMap { newsItem -> (String, News)? in
            guard let category = newsItem.category else { return nil }
            return (category, newsItem)
        }
        return Dictionary(grouping: categorizedNews, by: { $0.0 })
            .mapValues { $0.map { $0.1 } }
    }

    var availableCategories: [String] {
        guard case .success(let news) = state else { return [] }
        return Array(Set(news.compactMap { $0.category })).sorted()
    }

    // MARK: - Initialization

    init(fetchNewsUseCase: FetchNewsUseCase = FetchNewsUseCase()) {
        self.fetchNewsUseCase = fetchNewsUseCase
    }

    // MARK: - Public Methods

    func loadData() async {
        state = .loading

        do {
            let news: [News]

            if showFeaturedOnly {
                news = try await fetchNewsUseCase.executeFeatured()
            } else if let category = selectedCategory {
                news = try await fetchNewsUseCase.execute(category: category)
            } else {
                news = try await fetchNewsUseCase.execute()
            }

            state = .success(news)
        } catch {
            state = .failure(error)
        }
    }

    func refresh() async {
        await loadData()
    }

    func selectCategory(_ category: String?) {
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

    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        showFeaturedOnly = false
        Task {
            await loadData()
        }
    }
}
