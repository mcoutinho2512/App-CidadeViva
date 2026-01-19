import Foundation

@MainActor
final class CamerasViewModel: ObservableObject {
    @Published var cameras: [Camera] = []
    @Published var selectedCamera: Camera?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchCamerasUseCase: FetchCamerasUseCaseProtocol

    init(fetchCamerasUseCase: FetchCamerasUseCaseProtocol = FetchCamerasUseCase()) {
        self.fetchCamerasUseCase = fetchCamerasUseCase
    }

    func loadCameras() async {
        isLoading = true
        error = nil

        do {
            cameras = try await fetchCamerasUseCase.execute()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    var onlineCameras: [Camera] {
        cameras.filter { $0.isOnline }
    }

    var offlineCameras: [Camera] {
        cameras.filter { !$0.isOnline }
    }
}
