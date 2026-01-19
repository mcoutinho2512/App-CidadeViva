import Foundation

struct Camera: Identifiable, Equatable {
    let id: UUID
    let name: String
    let location: Location
    let streamURL: URL?
    let thumbnailURL: URL?
    let isOnline: Bool
    let lastUpdate: Date
}
