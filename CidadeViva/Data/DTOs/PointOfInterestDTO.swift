import Foundation

struct PointOfInterestDTO: Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let imageURL: String?
    let phone: String?
    let website: String?
    let openingHours: String?
    let rating: Double?

    func toDomain() -> PointOfInterest {
        PointOfInterest(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            description: description,
            category: PointOfInterest.Category(rawValue: category) ?? .publicService,
            location: Location(latitude: latitude, longitude: longitude, address: address),
            imageURL: imageURL.flatMap { URL(string: $0) },
            phone: phone,
            website: website.flatMap { URL(string: $0) },
            openingHours: openingHours,
            rating: rating
        )
    }
}
