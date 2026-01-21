import Foundation

protocol CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera]
}

final class CamerasRepository: CamerasRepositoryProtocol {
    func fetchCameras() async throws -> [Camera] {
        // Usa Firebase ou MockData
        // Para usar API REST, adicione APIService.swift ao target e mude useAPI para true
        if AppConfiguration.useFirebase {
            return try await FirestoreService.shared.fetchCameras()
        } else {
            return MockData.cameras
        }
    }
}
