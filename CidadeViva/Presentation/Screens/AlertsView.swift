import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.criticalAlerts.isEmpty {
                    Section {
                        ForEach(viewModel.criticalAlerts) { alert in
                            AlertRow(alert: alert)
                        }
                    } header: {
                        Label("Alertas Críticos", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Section("Todos os Alertas") {
                    ForEach(viewModel.filteredAlerts) { alert in
                        AlertRow(alert: alert)
                    }
                }
            }
            .navigationTitle("Alertas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Severidade", selection: $viewModel.selectedSeverity) {
                            Text("Todas").tag(nil as Alert.Severity?)
                            ForEach(Alert.Severity.allCases, id: \.self) { severity in
                                Text(severity.rawValue).tag(severity as Alert.Severity?)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.loadAlerts()
            }
            .overlay {
                if viewModel.isLoading && viewModel.alerts.isEmpty {
                    LoadingView()
                } else if viewModel.alerts.isEmpty && viewModel.error == nil {
                    EmptyStateView(
                        title: "Nenhum alerta",
                        systemImage: "checkmark.circle",
                        description: "Não há alertas no momento."
                    )
                }
            }
        }
        .task {
            await viewModel.loadAlerts()
        }
    }
}

struct AlertRow: View {
    let alert: Alert

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: alert.severity.iconName)
                    .foregroundStyle(alert.severity.color)

                Text(alert.title)
                    .font(.subheadline)
                    .bold()

                Spacer()

                Text(alert.severity.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(alert.severity.color.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text(alert.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Label(alert.category.rawValue, systemImage: "tag")

                Spacer()

                Text(alert.createdAt, style: .relative)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AlertsView()
}
