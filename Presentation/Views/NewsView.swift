//
//  NewsView.swift
//  CidadeViva
//
//  Tela de notícias da cidade
//

import SwiftUI

struct NewsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedNews: News?
    @State private var showFilters = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Notícias")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedNews) { news in
                NewsDetailView(news: news)
            }
            .sheet(isPresented: $showFilters) {
                NewsFiltersView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            Color.clear

        case .loading:
            ProgressView("Carregando notícias...")

        case .success:
            if viewModel.filteredNews.isEmpty {
                emptyState
            } else {
                newsList
            }

        case .failure(let error):
            ErrorView(
                message: error.localizedDescription,
                retryAction: {
                    Task {
                        await viewModel.loadData()
                    }
                }
            )
        }
    }

    private var newsList: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Featured News
                if !viewModel.featuredNews.isEmpty && viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Destaques")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.featuredNews) { news in
                                    FeaturedNewsCard(news: news)
                                        .onTapGesture {
                                            selectedNews = news
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Buscar notícias...")
                    .padding(.horizontal)

                // Category Filter
                if !viewModel.availableCategories.isEmpty && viewModel.searchText.isEmpty {
                    NewsCategoryFilterView(
                        categories: viewModel.availableCategories,
                        selectedCategory: $viewModel.selectedCategory,
                        onCategorySelected: { category in
                            viewModel.selectCategory(category)
                        }
                    )
                }

                // News List
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredNews) { news in
                        NewsCard(news: news)
                            .onTapGesture {
                                selectedNews = news
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Nenhuma notícia encontrada")
                .font(.headline)

            Text("Tente ajustar os filtros de busca")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                Button("Limpar Filtros") {
                    viewModel.clearFilters()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// MARK: - Featured News Card

struct FeaturedNewsCard: View {
    let news: News

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            if let imageURL = news.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 300, height: 180)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                if let category = news.category {
                    Text(category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Text(news.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(news.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                HStack {
                    if news.isRecent {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                            Text("Recente")
                        }
                        .font(.caption2)
                        .foregroundColor(.orange)
                    }

                    Spacer()

                    Text(news.publishedAtFormatted)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - News Card

struct NewsCard: View {
    let news: News

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image Thumbnail
            if let imageURL = news.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 6) {
                if let category = news.category {
                    Text(category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Text(news.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(news.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    if news.isFeatured {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                    }

                    if news.isRecent {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                            Text("Recente")
                        }
                        .font(.caption2)
                        .foregroundColor(.orange)
                    }

                    Spacer()

                    Text(news.publishedAtFormatted)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - News Category Filter View

struct NewsCategoryFilterView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    let onCategorySelected: (String?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                NewsCategoryChip(
                    title: "Todas",
                    isSelected: selectedCategory == nil,
                    action: {
                        onCategorySelected(nil)
                    }
                )

                ForEach(categories, id: \.self) { category in
                    NewsCategoryChip(
                        title: category,
                        isSelected: selectedCategory == category,
                        action: {
                            onCategorySelected(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct NewsCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - News Filters View

struct NewsFiltersView: View {
    @ObservedObject var viewModel: NewsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Filtros") {
                    Toggle("Apenas Destaques", isOn: Binding(
                        get: { viewModel.showFeaturedOnly },
                        set: { _ in viewModel.toggleFeatured() }
                    ))
                }

                Section {
                    Button("Limpar Todos os Filtros") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - News Detail View

struct NewsDetailView: View {
    let news: News
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image
                    if let imageURL = news.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 250)
                        .clipped()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        // Category Badge
                        if let category = news.category {
                            Text(category.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }

                        // Title
                        Text(news.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        // Metadata
                        HStack {
                            if let author = news.author {
                                Label(author, systemImage: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Label(news.publishedAtFormatted, systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if news.isFeatured {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Notícia em Destaque")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 8)
                        }

                        Divider()

                        // Summary
                        Text(news.summary)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        // Content
                        if let content = news.content {
                            Text(content)
                                .font(.body)
                                .lineSpacing(4)
                        }

                        // Source Link
                        if let sourceURL = news.sourceURL, let url = URL(string: sourceURL) {
                            Divider()

                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                HStack {
                                    Label("Ler Matéria Completa", systemImage: "link")
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }

                        // Expiration warning
                        if let expiresAt = news.expiresAt {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Esta notícia expira em \(news.dateFormatter.string(from: expiresAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}
