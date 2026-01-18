//
//  AlertsViewModel.swift
//  CidadeViva
//
//  ViewModel para a tela de Alertas
//

import Foundation
import Combine

/// ViewModel da tela de Alertas
@MainActor
final class AlertsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var alerts: [Alert] = []
    @Published var filteredAlerts: [Alert] = []
    @Published var loadingState: LoadingState = .idle
    @Published var selectedType: AlertType?
    @Published var selectedSeverity: AlertSeverity?
    @Published var showActiveOnly: Bool = true

    // MARK: - Properties

    private let fetchAlertsUseCase: FetchAlertsUseCase

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

    var activeAlertsCount: Int {
        alerts.filter { $0.isActive && !$0.isExpired }.count
    }

    var criticalAlertsCount: Int {
        alerts.filter { $0.severity == .critical && $0.isActive }.count
    }

    // MARK: - Initialization

    init(fetchAlertsUseCase: FetchAlertsUseCase = FetchAlertsUseCase()) {
        self.fetchAlertsUseCase = fetchAlertsUseCase
    }

    // MARK: - Public Methods

    /// Carrega lista de alertas
    func loadAlerts() async {
        loadingState = .loading

        do {
            let fetchedAlerts: [Alert]

            if showActiveOnly {
                fetchedAlerts = try await fetchAlertsUseCase.executeActiveOnly()
            } else {
                fetchedAlerts = try await fetchAlertsUseCase.execute()
            }

            self.alerts = fetchedAlerts
            self.filteredAlerts = fetchedAlerts
            self.loadingState = .success
            applyFilters()
        } catch {
            self.loadingState = .error(error)
        }
    }

    /// Atualiza os dados (pull to refresh)
    func refresh() async {
        CacheService.shared.remove(forKey: CacheService.CacheKey.alerts)
        await loadAlerts()
    }

    /// Aplica filtros à lista de alertas
    func applyFilters() {
        var result = alerts

        // Filtro por tipo
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }

        // Filtro por severidade
        if let severity = selectedSeverity {
            result = result.filter { $0.severity == severity }
        }

        // Filtro apenas ativos
        if showActiveOnly {
            result = result.filter { $0.isActive && !$0.isExpired }
        }

        filteredAlerts = result
    }

    /// Seleciona um tipo para filtro
    func selectType(_ type: AlertType?) {
        selectedType = type
        applyFilters()
    }

    /// Seleciona uma severidade para filtro
    func selectSeverity(_ severity: AlertSeverity?) {
        selectedSeverity = severity
        applyFilters()
    }

    /// Alterna entre mostrar todos ou apenas ativos
    func toggleShowActiveOnly() {
        showActiveOnly.toggle()
        Task {
            await loadAlerts()
        }
    }

    /// Limpa todos os filtros
    func clearFilters() {
        selectedType = nil
        selectedSeverity = nil
        applyFilters()
    }
}
