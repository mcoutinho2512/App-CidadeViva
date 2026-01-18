//
//  WeatherView.swift
//  CidadeViva
//
//  Tela de informações climáticas REDESENHADA - Premium
//

import SwiftUI

struct WeatherView: View {

    @ObservedObject var viewModel: WeatherViewModel
    
    @State private var particlesAnimation = false

    var body: some View {
        ZStack {
            // Fundo premium
            Color.backgroundDark
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingViewPremium(message: "Carregando dados climáticos...")

            case .success:
                if let weather = viewModel.weather {
                    weatherContent(weather: weather)
                } else {
                    emptyStatePremium
                }

            case .error(let error):
                ErrorViewPremium(error: error) {
                    Task {
                        await viewModel.loadWeather()
                    }
                }
            }
        }
        .navigationTitle("Clima")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
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
            VStack(spacing: Spacing.xxxl) {
                // Hero Weather Card imersivo
                heroWeatherSection(weather: weather)
                    .staggeredAppearance(index: 0)

                // Detalhes em grid premium
                weatherDetailsGrid(weather: weather)
                    .staggeredAppearance(index: 1)
                
                // Informação adicional
                additionalInfoCard(weather: weather)
                    .staggeredAppearance(index: 2)
            }
            .padding(Spacing.screenPadding)
            .tabBarSafeAreaPadding()
        }
    }

    // MARK: - Hero Weather Section

    private func heroWeatherSection(weather: Weather) -> some View {
        ZStack {
            // Gradiente dinâmico baseado na condição
            LinearGradient.forWeatherCondition(weather.condition.rawValue)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius))
                .frame(height: 500)
            
            // Overlay de vidro
            RoundedRectangle(cornerRadius: Spacing.cardRadius)
                .fill(.ultraThinMaterial)
                .frame(height: 500)
            
            VStack(spacing: Spacing.xl) {
                // Localização com ícone
                Label(weather.location, systemImage: "location.fill")
                    .font(.title3Custom)
                    .foregroundStyle(.white.opacity(0.9))
                
                // Ícone gigante animado
                Image(systemName: weather.condition.iconName)
                    .font(.system(size: 120))
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                    .shadow(color: .white.opacity(0.5), radius: 30)
                    .padding(.vertical, Spacing.lg)
                
                // Temperatura MASSIVE
                HStack(alignment: .top, spacing: 4) {
                    AnimatedDoubleCounter(value: weather.temperature, format: "%.0f")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("°")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(.white.opacity(0.7))
                        .offset(y: 8)
                }
                .shadow(color: .black.opacity(0.3), radius: 10)
                
                // Condição
                Text(weather.condition.description)
                    .font(.title1Custom)
                    .foregroundStyle(.white)
                
                // Sensação térmica
                Text(weather.feelsLikeFormatted)
                    .font(.title3Custom)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(Spacing.xxxl)
        }
        .floatingShadow(intensity: 2.0)
    }

    // MARK: - Weather Details Grid

    private func weatherDetailsGrid(weather: Weather) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ],
            spacing: Spacing.md
        ) {
            weatherMetricCard(
                icon: "humidity.fill",
                label: "Umidade",
                value: weather.humidityFormatted,
                gradient: .ocean
            )
            
            weatherMetricCard(
                icon: "wind",
                label: "Vento",
                value: weather.windSpeedFormatted,
                gradient: .forest
            )
        }
    }
    
    private func weatherMetricCard(
        icon: String,
        label: String,
        value: String,
        gradient: LinearGradient
    ) -> some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 60, height: 60)
                    .glow(color: Color.oceanStart, radius: 15)
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse)
            }
            
            VStack(spacing: Spacing.xs) {
                Text(value)
                    .font(.title2Custom)
                    .foregroundStyle(Color.textPrimary)
                
                Text(label)
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .glassCard()
    }

    // MARK: - Additional Info Card

    private func additionalInfoCard(weather: Weather) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Label("Informações Adicionais", systemImage: "info.circle.fill")
                .font(.title3Custom)
                .foregroundStyle(Color.textPrimary)
            
            Divider()
                .background(Color.textSecondary.opacity(0.3))
            
            infoRow(
                icon: "clock.fill",
                label: "Última Atualização",
                value: weather.lastUpdatedFormatted
            )
        }
        .padding(Spacing.xl)
        .glassCard(padding: 0)
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(
                    LinearGradient.primary
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
                
                Text(value)
                    .font(.bodyCustom)
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
        }
    }

    // MARK: - Empty State Premium

    private var emptyStatePremium: some View {
        VStack(spacing: Spacing.xxxl) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.textSecondary.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "cloud.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: Spacing.md) {
                Text("Nenhum dado climático disponível")
                    .font(.title2Custom)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Tente novamente mais tarde")
                    .font(.bodyCustom)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        WeatherView(viewModel: WeatherViewModel())
            .preferredColorScheme(.dark)
    }
}
