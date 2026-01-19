import Foundation

struct EventDTO: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let startDate: String
    let endDate: String?
    let imageURL: String?
    let organizer: String?
    let isFree: Bool
    let price: Double?

    func toDomain() -> Event {
        Event(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description,
            category: Event.Category(rawValue: category) ?? .community,
            location: Location(latitude: latitude, longitude: longitude, address: address),
            startDate: ISO8601DateFormatter().date(from: startDate) ?? Date(),
            endDate: endDate.flatMap { ISO8601DateFormatter().date(from: $0) },
            imageURL: imageURL.flatMap { URL(string: $0) },
            organizer: organizer,
            isFree: isFree,
            price: price
        )
    }
}
