import Foundation

protocol EventsRepositoryProtocol {
    func fetchEvents() async throws -> [Event]
}

final class EventsRepository: EventsRepositoryProtocol {
    func fetchEvents() async throws -> [Event] {
        // TODO: Implement API call
        return MockData.events
    }
}
