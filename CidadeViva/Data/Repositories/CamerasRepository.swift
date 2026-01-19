import Foundation

protocol CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera]
}

final class CamerasRepository: CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera] {
        if AppConfiguration.useFirebase {
            return try await FirestoreService.shared.fetchCameras()
        } else {
            return MockData.cameras
        }
    }
}
