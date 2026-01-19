import Foundation

struct Event: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let category: Category
    let location: Location
    let startDate: Date
    let endDate: Date?
    let imageURL: URL?
    let organizer: String?
    let isFree: Bool
    let price: Double?

    enum Category: String, CaseIterable {
        case cultural = "Cultural"
        case sports = "Esportes"
        case music = "Música"
        case education = "Educação"
        case health = "Saúde"
        case community = "Comunitário"
        case government = "Governo"

        var iconName: String {
            switch self {
            case .cultural: return "theatermasks.fill"
            case .sports: return "sportscourt.fill"
            case .music: return "music.note"
            case .education: return "book.fill"
            case .health: return "heart.fill"
            case .community: return "person.3.fill"
            case .government: return "building.columns.fill"
            }
        }
    }
}
