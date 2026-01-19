import Foundation
import CoreLocation

struct Location: Identifiable, Equatable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let address: String?
    let neighborhood: String?
    let city: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: UUID = UUID(), latitude: Double, longitude: Double, address: String? = nil, neighborhood: String? = nil, city: String = "João Pessoa") {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.neighborhood = neighborhood
        self.city = city
    }
}
