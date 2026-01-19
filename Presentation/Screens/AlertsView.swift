//
//  AlertsView.swift
//  CidadeViva
//
//  Tela de alertas urbanos
//

import SwiftUI

struct AlertsView: View {

    @ObservedObject var viewModel: AlertsViewModel
    @State private var showFilterSheet = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView(message: "Carregando alertas...")

            case .success:
                alertsContent

            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadAlerts()
                    }
                }
            }
        }
        .navigationTitle("Alertas")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilterSheet = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
        }
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadAlerts()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Alerts Content

    private var alertsContent: some View {
        VStack(spacing: 0) {
            // Estatísticas
            statsBar

            // Lista de alertas
            if viewModel.filteredAlerts.isEmpty {
                emptyStateView
            } else {
                alertsList
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 20) {
            statItem(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.activeAlertsCount)",
                label: "Ativos",
                color: Color("SecondaryColor")
            )

            Divider()
                .frame(height: 30)

            statItem(
                icon: "exclamationmark.triangle.fill",
                value: "\(viewModel.criticalAlertsCount)",
                label: "Críticos",
                color: Color("AlertColor")
            )

            Spacer()

            Toggle("Apenas Ativos", isOn: Binding(
                get: { viewModel.showActiveOnly },
                set: { _ in viewModel.toggleShowActiveOnly() }
            ))
            .font(.caption)
            .toggleStyle(SwitchToggleStyle(tint: Color("PrimaryColor")))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Alerts List

    private var alertsList: some View {
        List {
            ForEach(viewModel.filteredAlerts) { alert in
                alertRow(alert: alert)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func alertRow(alert: Alert) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header com tipo e severidade
            HStack {
                Label(alert.type.description, systemImage: alert.type.iconName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                severityBadge(alert.severity)
            }

            // Título
            Text(alert.title)
                .font(.headline)

            // Descrição
            Text(alert.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            // Footer
            HStack {
                Label(alert.location, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(alert.createdAtFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: AppConfiguration.UI.cardCornerRadius)
                .strokeBorder(Color(alert.severity.colorName), lineWidth: 2)
        )
    }

    private func severityBadge(_ severity: AlertSeverity) -> some View {
        Text(severity.description.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(severity.colorName))
            .cornerRadius(4)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("SecondaryColor"))

            Text("Nenhum alerta no momento")
                .font(.headline)

            Text("Tudo tranquilo por aqui!")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if viewModel.selectedType != nil || viewModel.selectedSeverity != nil {
                Button("Limpar Filtros") {
                    viewModel.clearFilters()
                }
                .foregroundColor(Color("PrimaryColor"))
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Tipo de Alerta") {
                    Picker("Tipo", selection: Binding(
                        get: { viewModel.selectedType },
                        set: { viewModel.selectType($0) }
                    )) {
                        Text("Todos").tag(nil as AlertType?)
                        Text("Trânsito").tag(AlertType.traffic as AlertType?)
                        Text("Clima").tag(AlertType.weather as AlertType?)
                        Text("Segurança").tag(AlertType.security as AlertType?)
                        Text("Infraestrutura").tag(AlertType.infrastructure as AlertType?)
                        Text("Evento").tag(AlertType.event as AlertType?)
                        Text("Emergência").tag(AlertType.emergency as AlertType?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section("Severidade") {
                    Picker("Severidade", selection: Binding(
                        get: { viewModel.selectedSeverity },
                        set: { viewModel.selectSeverity($0) }
                    )) {
                        Text("Todas").tag(nil as AlertSeverity?)
                        Text("Baixa").tag(AlertSeverity.low as AlertSeverity?)
                        Text("Média").tag(AlertSeverity.medium as AlertSeverity?)
                        Text("Alta").tag(AlertSeverity.high as AlertSeverity?)
                        Text("Crítica").tag(AlertSeverity.critical as AlertSeverity?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section {
                    Button("Limpar Todos os Filtros") {
                        viewModel.clearFilters()
                        showFilterSheet = false
                    }
                    .foregroundColor(Color("AlertColor"))
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        showFilterSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlertsView(viewModel: AlertsViewModel())
    }
}
