import Foundation

protocol EventsRepositoryProtocol {
    func fetchEvents() async throws -> [Event]
}

final class EventsRepository: EventsRepositoryProtocol {
    func fetchEvents() async throws -> [Event] {
        if AppConfiguration.useFirebase {
            return try await FirestoreService.shared.fetchEvents()
        } else {
            return MockData.events
        }
    }
}
