import Foundation

protocol CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera]
}

final class CamerasRepository: CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera] {
        // TODO: Implement API call
        return MockData.cameras
    }
}
