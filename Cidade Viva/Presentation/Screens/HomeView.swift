//
//  HomeView.swift
//  CidadeViva
//
//  Tela principal REDESENHADA - Design Premium & Futurista
//  Inspirado em: Apple Weather, Stripe, Arc Browser
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    
    @State private var headerAppeared = false
    @State private var refreshProgress: CGFloat = 0

    var body: some View {
        ZStack {
            // Fundo gradiente premium
            Color.backgroundDark
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingViewPremium(message: "Carregando informações da cidade...")

            case .success:
                successView

            case .error(let error):
                ErrorViewPremium(error: error) {
                    Task {
                        await viewModel.loadData()
                    }
                }
            }
        }
        .navigationTitle("CidadeViva")
        .preferredColorScheme(.dark)
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
            VStack(spacing: Spacing.xl) {
                // Hero Header com animação
                heroHeader
                    .staggeredAppearance(index: 0)
                
                // Card de Clima HERO
                if let weather = viewModel.weather {
                    HeroWeatherCard(weather: weather)
                        .staggeredAppearance(index: 1)
                }
                
                // Quick Stats
                quickStatsSection
                    .staggeredAppearance(index: 2)

                // Cards de resumo com novo design
                summaryCardsSection
                    .staggeredAppearance(index: 3)
            }
            .padding(Spacing.screenPadding)
            .tabBarSafeAreaPadding()
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: Spacing.md) {
            // Título com gradiente
            Text("Informações da Cidade")
                .font(.title1Custom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.textPrimary, Color.textSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Última atualização com ícone
            HStack(spacing: Spacing.xs) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                
                Text(viewModel.lastUpdatedText)
                    .font(.captionCustom)
            }
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        HStack(spacing: Spacing.md) {
            MiniGlassCard(
                icon: "video.fill",
                value: "\(viewModel.camerasCount)",
                label: "Câmeras",
                color: .accentCyan
            )
            
            MiniGlassCard(
                icon: viewModel.activeAlertsCount > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                value: "\(viewModel.activeAlertsCount)",
                label: "Alertas",
                color: viewModel.activeAlertsCount > 0 ? .errorVibrant : .successNeon
            )
        }
    }

    // MARK: - Summary Cards

    private var summaryCardsSection: some View {
        VStack(spacing: Spacing.cardSpacing) {
            // Câmeras
            GlassCard(
                icon: "video.fill",
                title: "Câmeras de Monitoramento",
                value: "\(viewModel.camerasCount)",
                subtitle: "câmeras disponíveis",
                gradient: .ocean,
                action: {
                    // Navegação para câmeras
                }
            )

            // Alertas
            GlassCard(
                icon: "exclamationmark.triangle.fill",
                title: "Alertas Ativos",
                value: "\(viewModel.activeAlertsCount)",
                subtitle: viewModel.activeAlertsCount > 0 ? "requerem atenção" : "nenhum alerta no momento",
                gradient: viewModel.activeAlertsCount > 0 ? .fire : .forest,
                action: {
                    // Navegação para alertas
                }
            )
        }
    }
}

// MARK: - Loading Premium

struct LoadingViewPremium: View {
    
    let message: String
    
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Loader customizado com gradiente
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient.primary,
                        lineWidth: 4
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient.ocean,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            Text(message)
                .font(.bodyCustom)
                .foregroundStyle(Color.textSecondary)
                .pulsing()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error Premium

struct ErrorViewPremium: View {
    
    let error: Error
    let retryAction: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            // Ícone com gradiente
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.errorVibrant.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.errorVibrant, Color.warningGold],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .pulsing()

            VStack(spacing: Spacing.lg) {
                Text("Ops! Algo deu errado")
                    .font(.title1Custom)
                    .foregroundStyle(Color.textPrimary)

                Text(error.localizedDescription)
                    .font(.bodyCustom)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxxl)
            }

            Button(action: {
                retryAction()
            }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "arrow.clockwise")
                    Text("Tentar Novamente")
                }
                .font(.title3Custom)
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.xxxl)
                .padding(.vertical, Spacing.lg)
                .background(
                    Capsule()
                        .fill(LinearGradient.primary)
                )
                .glow(color: .primaryStart, radius: 20)
            }
            .bouncePress()
        }
        .padding(Spacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.9)
        .onAppear {
            withAnimation(.smooth) {
                appeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel())
            .preferredColorScheme(.dark)
    }
}
