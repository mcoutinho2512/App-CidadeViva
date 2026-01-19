import Foundation

struct NewsDTO: Codable {
    let id: String
    let title: String
    let summary: String
    let content: String
    let category: String
    let imageURL: String?
    let source: String
    let publishedAt: String
    let url: String?

    func toDomain() -> News {
        News(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            summary: summary,
            content: content,
            category: News.Category(rawValue: category) ?? .general,
            imageURL: imageURL.flatMap { URL(string: $0) },
            source: source,
            publishedAt: ISO8601DateFormatter().date(from: publishedAt) ?? Date(),
            url: url.flatMap { URL(string: $0) }
        )
    }
}
