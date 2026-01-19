import Foundation

protocol FetchEventsUseCaseProtocol {
    func execute() async throws -> [Event]
}

final class FetchEventsUseCase: FetchEventsUseCaseProtocol {
    private let repository: EventsRepositoryProtocol

    init(repository: EventsRepositoryProtocol = EventsRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Event] {
        try await repository.fetchEvents()
    }
}
