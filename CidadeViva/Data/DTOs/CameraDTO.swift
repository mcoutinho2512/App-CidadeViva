import Foundation

struct CameraDTO: Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let streamURL: String?
    let thumbnailURL: String?
    let isOnline: Bool
    let lastUpdate: String

    func toDomain() -> Camera {
        Camera(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            location: Location(latitude: latitude, longitude: longitude, address: address),
            streamURL: streamURL.flatMap { URL(string: $0) },
            thumbnailURL: thumbnailURL.flatMap { URL(string: $0) },
            isOnline: isOnline,
            lastUpdate: ISO8601DateFormatter().date(from: lastUpdate) ?? Date()
        )
    }
}
