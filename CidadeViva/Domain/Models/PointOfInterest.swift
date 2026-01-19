import Foundation

struct PointOfInterest: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let category: Category
    let location: Location
    let imageURL: URL?
    let phone: String?
    let website: URL?
    let openingHours: String?
    let rating: Double?

    enum Category: String, CaseIterable {
        case hospital = "Hospital"
        case pharmacy = "Farmácia"
        case police = "Polícia"
        case fireStation = "Bombeiros"
        case school = "Escola"
        case university = "Universidade"
        case park = "Parque"
        case beach = "Praia"
        case museum = "Museu"
        case publicService = "Serviço Público"
        case transport = "Transporte"
        case tourism = "Turismo"

        var iconName: String {
            switch self {
            case .hospital: return "cross.fill"
            case .pharmacy: return "pills.fill"
            case .police: return "shield.fill"
            case .fireStation: return "flame.fill"
            case .school: return "book.fill"
            case .university: return "graduationcap.fill"
            case .park: return "leaf.fill"
            case .beach: return "beach.umbrella.fill"
            case .museum: return "building.columns.fill"
            case .publicService: return "person.badge.clock.fill"
            case .transport: return "bus.fill"
            case .tourism: return "camera.fill"
            }
        }
    }
}
