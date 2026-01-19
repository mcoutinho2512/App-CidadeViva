import Foundation

struct Banner: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageURL: URL?
    let linkURL: URL?
    let order: Int
    let isActive: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        imageURL: URL? = nil,
        linkURL: URL? = nil,
        order: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.linkURL = linkURL
        self.order = order
        self.isActive = isActive
    }
}
