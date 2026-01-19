import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredNews) { item in
                    NewsRow(news: item)
                }
            }
            .navigationTitle("Notícias")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Todas") {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(News.Category.allCases, id: \.self) { category in
                            Button {
                                viewModel.selectedCategory = category
                            } label: {
                                Label(category.rawValue, systemImage: category.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.loadNews()
            }
            .overlay {
                if viewModel.isLoading && viewModel.news.isEmpty {
                    LoadingView()
                }
            }
        }
        .task {
            await viewModel.loadNews()
        }
    }
}

struct NewsRow: View {
    let news: News

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: news.category.iconName)
                    .foregroundStyle(AppConfiguration.primaryBlue)

                Text(news.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(news.publishedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(news.title)
                .font(.headline)

            Text(news.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Text(news.source)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NewsListView()
}
