//
//  WeatherView.swift
//  CidadeViva
//
//  Tela de informações climáticas detalhadas
//

import SwiftUI

struct WeatherView: View {

    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView(message: "Carregando dados climáticos...")

            case .success:
                if let weather = viewModel.weather {
                    weatherContent(weather: weather)
                } else {
                    emptyStateView
                }

            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadWeather()
                    }
                }
            }
        }
        .navigationTitle("Clima")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadWeather()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Weather Content

    private func weatherContent(weather: Weather) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Localização
                Text(weather.location)
                    .font(.title3)
                    .foregroundColor(.secondary)

                // Temperatura principal
                VStack(spacing: 8) {
                    Image(systemName: weather.condition.iconName)
                        .font(.system(size: 100))
                        .foregroundColor(.orange)
                        .symbolRenderingMode(.hierarchical)
                        .padding()

                    Text(weather.temperatureFormatted)
                        .font(.system(size: 72, weight: .thin))

                    Text(weather.condition.description)
                        .font(.title)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 20)

                // Sensação térmica
                Text(weather.feelsLikeFormatted)
                    .font(.title3)
                    .foregroundColor(.secondary)

                // Detalhes em cards
                VStack(spacing: 16) {
                    detailCard(
                        icon: "humidity.fill",
                        title: "Umidade",
                        value: weather.humidityFormatted,
                        color: Color("PrimaryColor")
                    )

                    detailCard(
                        icon: "wind",
                        title: "Velocidade do Vento",
                        value: weather.windSpeedFormatted,
                        color: Color("SecondaryColor")
                    )

                    detailCard(
                        icon: "clock.fill",
                        title: "Última Atualização",
                        value: weather.lastUpdatedFormatted,
                        color: .gray
                    )
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }

    // MARK: - Detail Card

    private func detailCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Nenhum dado climático disponível")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        WeatherView(viewModel: WeatherViewModel())
    }
}
