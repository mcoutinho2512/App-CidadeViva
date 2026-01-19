import Foundation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedCategory: Event.Category?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchEventsUseCase: FetchEventsUseCaseProtocol

    init(fetchEventsUseCase: FetchEventsUseCaseProtocol = FetchEventsUseCase()) {
        self.fetchEventsUseCase = fetchEventsUseCase
    }

    func loadEvents() async {
        isLoading = true
        error = nil

        do {
            events = try await fetchEventsUseCase.execute()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var filteredEvents: [Event] {
        guard let category = selectedCategory else {
            return events.sorted { $0.startDate < $1.startDate }
        }
        return events.filter { $0.category == category }.sorted { $0.startDate < $1.startDate }
    }

    var upcomingEvents: [Event] {
        events.filter { $0.startDate > Date() }.sorted { $0.startDate < $1.startDate }
    }

    var todayEvents: [Event] {
        let calendar = Calendar.current
        return events.filter { calendar.isDateInToday($0.startDate) }
    }
}
