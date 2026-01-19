import Foundation

struct News: Identifiable, Equatable {
    let id: UUID
    let title: String
    let summary: String
    let content: String
    let category: Category
    let imageURL: URL?
    let source: String
    let publishedAt: Date
    let url: URL?

    enum Category: String, CaseIterable {
        case general = "Geral"
        case politics = "Política"
        case economy = "Economia"
        case health = "Saúde"
        case education = "Educação"
        case sports = "Esportes"
        case culture = "Cultura"
        case infrastructure = "Infraestrutura"

        var iconName: String {
            switch self {
            case .general: return "newspaper.fill"
            case .politics: return "building.columns.fill"
            case .economy: return "chart.line.uptrend.xyaxis"
            case .health: return "heart.fill"
            case .education: return "book.fill"
            case .sports: return "sportscourt.fill"
            case .culture: return "theatermasks.fill"
            case .infrastructure: return "road.lanes"
            }
        }
    }
}
