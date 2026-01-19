import Foundation

@MainActor
final class POIsViewModel: ObservableObject {
    @Published var pointsOfInterest: [PointOfInterest] = []
    @Published var selectedCategory: PointOfInterest.Category?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchPOIsUseCase: FetchPOIsUseCaseProtocol

    init(fetchPOIsUseCase: FetchPOIsUseCaseProtocol = FetchPOIsUseCase()) {
        self.fetchPOIsUseCase = fetchPOIsUseCase
    }

    func loadPOIs() async {
        isLoading = true
        error = nil

        do {
            if let category = selectedCategory {
                pointsOfInterest = try await fetchPOIsUseCase.execute(category: category)
            } else {
                pointsOfInterest = try await fetchPOIsUseCase.execute()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var filteredPOIs: [PointOfInterest] {
        var result = pointsOfInterest

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }

    func filterByCategory(_ category: PointOfInterest.Category?) {
        selectedCategory = category
        Task {
            await loadPOIs()
        }
    }
}
