import SwiftUI

struct POIsListView: View {
    @StateObject private var viewModel = POIsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredPOIs) { poi in
                    POIRow(poi: poi)
                }
            }
            .navigationTitle("Pontos de Interesse")
            .searchable(text: $viewModel.searchText, prompt: "Buscar local")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Todos") {
                            viewModel.filterByCategory(nil)
                        }
                        ForEach(PointOfInterest.Category.allCases, id: \.self) { category in
                            Button {
                                viewModel.filterByCategory(category)
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
                await viewModel.loadPOIs()
            }
            .overlay {
                if viewModel.isLoading && viewModel.pointsOfInterest.isEmpty {
                    LoadingView()
                }
            }
        }
        .task {
            await viewModel.loadPOIs()
        }
    }
}

struct POIRow: View {
    let poi: PointOfInterest

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: poi.category.iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(AppConfiguration.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.headline)

                Text(poi.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let address = poi.location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let rating = poi.rating {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    POIsListView()
}
