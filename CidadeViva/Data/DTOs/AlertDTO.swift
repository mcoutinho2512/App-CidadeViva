import Foundation

struct AlertDTO: Codable {
    let id: String
    let title: String
    let description: String
    let severity: String
    let category: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let createdAt: String
    let expiresAt: String?

    func toDomain() -> Alert {
        var location: Location? = nil
        if let lat = latitude, let lng = longitude {
            location = Location(latitude: lat, longitude: lng, address: address)
        }

        return Alert(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description,
            severity: Alert.Severity(rawValue: severity) ?? .medium,
            category: Alert.Category(rawValue: category) ?? .traffic,
            location: location,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            expiresAt: expiresAt.flatMap { ISO8601DateFormatter().date(from: $0) }
        )
    }
}
