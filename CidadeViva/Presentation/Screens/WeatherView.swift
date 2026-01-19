import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if let weather = viewModel.weather {
                    VStack(spacing: 24) {
                        // Main Weather Card
                        VStack(spacing: 16) {
                            Image(systemName: weather.condition.iconName)
                                .font(.system(size: 80))
                                .foregroundStyle(.yellow)

                            Text("\(Int(weather.temperature))°C")
                                .font(.system(size: 64, weight: .thin))

                            Text(weather.condition.rawValue)
                                .font(.title2)
                                .foregroundStyle(.secondary)

                            Text(weather.location)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 32)

                        // Details
                        HStack(spacing: 32) {
                            WeatherDetailItem(
                                icon: "humidity.fill",
                                title: "Umidade",
                                value: "\(weather.humidity)%"
                            )

                            WeatherDetailItem(
                                icon: "wind",
                                title: "Vento",
                                value: "\(Int(weather.windSpeed)) km/h"
                            )
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Last Update
                        Text("Atualizado: \(weather.updatedAt, style: .relative)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if viewModel.error != nil {
                    ErrorView(message: "Erro ao carregar dados do clima") {
                        Task { await viewModel.loadWeather() }
                    }
                }
            }
            .navigationTitle("Clima")
            .refreshable {
                await viewModel.loadWeather()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        }
        .task {
            await viewModel.loadWeather()
        }
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppConfiguration.primaryBlue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
    }
}

#Preview {
    WeatherView()
}
