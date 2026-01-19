//
//  HomeView.swift
//  CidadeViva
//
//  Tela principal do aplicativo com resumo de informações
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView(message: "Carregando informações da cidade...")

            case .success:
                successView

            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadData()
                    }
                }
            }
        }
        .navigationTitle("CidadeViva")
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadData()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Success View

    private var successView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header com última atualização
                headerView

                // Card de Clima
                if let weather = viewModel.weather {
                    weatherCard(weather: weather)
                }

                // Cards de resumo
                VStack(spacing: 16) {
                    // Câmeras
                    InfoCard(
                        icon: "video.fill",
                        title: "Câmeras de Monitoramento",
                        value: "\(viewModel.camerasCount)",
                        subtitle: "câmeras disponíveis",
                        iconColor: Color("SecondaryColor")
                    )

                    // Alertas
                    InfoCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Alertas Ativos",
                        value: "\(viewModel.activeAlertsCount)",
                        subtitle: viewModel.activeAlertsCount > 0 ? "requerem atenção" : "nenhum alerta no momento",
                        iconColor: viewModel.activeAlertsCount > 0 ? Color("AlertColor") : Color("SecondaryColor")
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Informações da Cidade")
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.lastUpdatedText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Weather Card

    private func weatherCard(weather: Weather) -> some View {
        VStack(spacing: 16) {
            // Ícone e temperatura
            HStack(spacing: 20) {
                Image(systemName: weather.condition.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .symbolRenderingMode(.hierarchical)

                VStack(alignment: .leading, spacing: 4) {
                    Text(weather.temperatureFormatted)
                        .font(.system(size: 48, weight: .bold))

                    Text(weather.condition.description)
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text(weather.feelsLikeFormatted)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // Detalhes adicionais
            HStack(spacing: 20) {
                weatherDetailItem(
                    icon: "humidity.fill",
                    title: "Umidade",
                    value: weather.humidityFormatted
                )

                Divider()
                    .frame(height: 40)

                weatherDetailItem(
                    icon: "wind",
                    title: "Vento",
                    value: weather.windSpeedFormatted
                )
            }
        }
        .padding(20)
        .cardStyle()
    }

    private func weatherDetailItem(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel())
    }
}
