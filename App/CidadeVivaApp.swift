//
//  CidadeVivaApp.swift
//  CidadeViva
//
//  Ponto de entrada principal do aplicativo
//  Configuração inicial e injeção de dependências
//

import SwiftUI

@main
struct CidadeVivaApp: App {

    // MARK: - Properties

    @StateObject private var appRouter = AppRouter()

    // MARK: - Initialization

    init() {
        configureAppearance()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appRouter)
                .preferredColorScheme(nil) // Suporte a dark mode automático
        }
    }

    // MARK: - Configuration

    /// Configura a aparência global do aplicativo
    private func configureAppearance() {
        // Configuração de cores da navegação
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Configuração da TabBar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

// MARK: - Content View

/// View principal com navegação por tabs
struct ContentView: View {

    @State private var selectedTab = 0
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var camerasViewModel = CamerasViewModel()
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var mapViewModel = MapViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView(viewModel: homeViewModel)
            }
            .tabItem {
                Label("Início", systemImage: "house.fill")
            }
            .tag(0)

            // Eventos Tab
            EventsView()
                .tabItem {
                    Label("Eventos", systemImage: "calendar")
                }
                .tag(1)

            // Notícias Tab
            NewsView()
                .tabItem {
                    Label("Notícias", systemImage: "newspaper")
                }
                .tag(2)

            // POIs Tab
            POIsView()
                .tabItem {
                    Label("Pontos", systemImage: "mappin.and.ellipse")
                }
                .tag(3)

            // Navegação Tab
            NavigationView()
                .tabItem {
                    Label("Rotas", systemImage: "map")
                }
                .tag(4)

            // Clima Tab
            NavigationStack {
                WeatherView(viewModel: weatherViewModel)
            }
            .tabItem {
                Label("Clima", systemImage: "cloud.sun.fill")
            }
            .tag(5)

            // Câmeras Tab
            NavigationStack {
                CamerasView(viewModel: camerasViewModel)
            }
            .tabItem {
                Label("Câmeras", systemImage: "video.fill")
            }
            .tag(6)

            // Alertas Tab
            NavigationStack {
                AlertsView(viewModel: alertsViewModel)
            }
            .tabItem {
                Label("Alertas", systemImage: "exclamationmark.triangle.fill")
            }
            .badge(alertsViewModel.activeAlertsCount)
            .tag(7)

            // Mapa Tab
            NavigationStack {
                MapView(viewModel: mapViewModel)
            }
            .tabItem {
                Label("Mapa", systemImage: "map.fill")
            }
            .tag(8)
        }
        .tint(Color("PrimaryColor"))
    }
}
