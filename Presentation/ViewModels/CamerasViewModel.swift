//
//  CamerasViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de Câmeras
//

import Foundation

/// ViewModel da tela de Câmeras
@MainActor
final class CamerasViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var cameras: [Camera] = []
    @Published var filteredCameras: [Camera] = []
    @Published var loadingState: LoadingState = .idle
    @Published var selectedRegion: CityRegion = .all
    @Published var selectedStatus: CameraStatus?
    @Published var searchText: String = ""

    // MARK: - Properties

    private let fetchCamerasUseCase: FetchCamerasUseCase

    // MARK: - Computed Properties

    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .error(let error) = loadingState {
            return error.localizedDescription
        }
        return nil
    }

    var onlineCamerasCount: Int {
        cameras.filter { $0.status == .online }.count
    }

    var offlineCamerasCount: Int {
        cameras.filter { $0.status == .offline }.count
    }

    // MARK: - Initialization

    init(fetchCamerasUseCase: FetchCamerasUseCase = FetchCamerasUseCase()) {
        self.fetchCamerasUseCase = fetchCamerasUseCase
    }

    // MARK: - Public Methods

    /// Carrega lista de câmeras
    func loadCameras() async {
        loadingState = .loading

        do {
            let fetchedCameras = try await fetchCamerasUseCase.execute()
            self.cameras = fetchedCameras
            self.filteredCameras = fetchedCameras
            self.loadingState = .success
            applyFilters()
        } catch {
            self.loadingState = .error(error)
        }
    }

    /// Atualiza os dados (pull to refresh)
    func refresh() async {
        CacheService.shared.remove(forKey: CacheService.CacheKey.cameras)
        await loadCameras()
    }

    /// Aplica filtros à lista de câmeras
    func applyFilters() {
        var result = cameras

        // Filtro por região
        if selectedRegion != .all {
            result = result.filter { $0.region == selectedRegion.rawValue }
        }

        // Filtro por status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        // Filtro por texto de busca
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.region.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredCameras = result
    }

    /// Seleciona uma região para filtro
    func selectRegion(_ region: CityRegion) {
        selectedRegion = region
        applyFilters()
    }

    /// Seleciona um status para filtro
    func selectStatus(_ status: CameraStatus?) {
        selectedStatus = status
        applyFilters()
    }

    /// Atualiza o texto de busca
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }

    /// Limpa todos os filtros
    func clearFilters() {
        selectedRegion = .all
        selectedStatus = nil
        searchText = ""
        applyFilters()
    }
}
