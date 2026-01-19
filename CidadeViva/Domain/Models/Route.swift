import Foundation
import MapKit

struct Route: Identifiable, Equatable {
    let id: UUID
    let origin: Location
    let destination: Location
    let distance: Double // em metros
    let duration: TimeInterval // em segundos
    let transportType: TransportType
    let polyline: [Location]?

    enum TransportType: String, CaseIterable {
        case walking = "A pé"
        case driving = "Carro"
        case transit = "Transporte Público"
        case cycling = "Bicicleta"

        var iconName: String {
            switch self {
            case .walking: return "figure.walk"
            case .driving: return "car.fill"
            case .transit: return "bus.fill"
            case .cycling: return "bicycle"
            }
        }
    }

    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }

    var formattedDuration: String {
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)min"
        }
        return "\(minutes) min"
    }
}
