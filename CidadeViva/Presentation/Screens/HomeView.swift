import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showLanguageSelector = false
    @State private var activeSection: String = "eventos"
    @State private var unreadAlertsCount: Int = 0
    @State private var hasViewedAlerts: Bool = false

    var body: some View {
        ZStack {
            // Background
            AppConfiguration.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header fixo
                HeaderView(
                    showLanguageSelector: $showLanguageSelector,
                    alertCount: unreadAlertsCount,
                    onAlertsTap: {
                        scrollToSection("alertas")
                    }
                )

                // Conteúdo com scroll spy
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            // Banner Hero
                            BannerView()

                            // Seção com header sticky
                            Section {
                                // SEÇÃO EVENTOS
                                EventosSection(events: viewModel.events)
                                    .id("eventos")
                                    .onAppear { updateActiveSection("eventos") }

                                // SEÇÃO ALERTAS
                                AlertasSection(alerts: viewModel.alerts)
                                    .id("alertas")
                                    .onAppear {
                                        updateActiveSection("alertas")
                                        markAlertsAsRead()
                                    }

                                // SEÇÃO CÂMERAS
                                CamerasSection(cameras: viewModel.cameras)
                                    .id("cameras")
                                    .onAppear { updateActiveSection("cameras") }

                                // SEÇÃO MAPA
                                MapaSection(pointsOfInterest: viewModel.pointsOfInterest)
                                    .id("mapa")
                                    .onAppear { updateActiveSection("mapa") }

                                // SEÇÃO TRANSPORTE
                                TransporteSection()
                                    .id("transporte")
                                    .onAppear { updateActiveSection("transporte") }

                            } header: {
                                // Botões de navegação STICKY
                                NavigationButtonsBar(activeSection: $activeSection) { section in
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(section, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView(isPresented: $showLanguageSelector)
        }
        .task {
            await viewModel.loadData()
            // Inicializa o contador de alertas não lidos
            updateUnreadAlertsCount()
        }
        .refreshable {
            await viewModel.loadData()
            // Ao atualizar, reseta o estado de visualização e atualiza contador
            hasViewedAlerts = false
            updateUnreadAlertsCount()
        }
        .onChange(of: viewModel.alerts) { _ in
            // Atualiza contador quando os alertas mudam
            if !hasViewedAlerts {
                updateUnreadAlertsCount()
            }
        }
    }

    private func updateActiveSection(_ section: String) {
        if activeSection != section {
            activeSection = section
            // Haptic feedback ao mudar seção
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }

    private func scrollToSection(_ section: String) {
        activeSection = section
    }

    private func updateUnreadAlertsCount() {
        unreadAlertsCount = viewModel.alerts.count
    }

    private func markAlertsAsRead() {
        // Marca como lido e zera o contador
        hasViewedAlerts = true
        withAnimation(.easeOut(duration: 0.3)) {
            unreadAlertsCount = 0
        }
    }
}

// MARK: - Language Selector
struct LanguageSelectorView: View {
    @Binding var isPresented: Bool
    @State private var selectedLanguage = "pt-BR"

    let languages = [
        ("pt-BR", "Português (Brasil)", "🇧🇷"),
        ("en", "English", "🇺🇸"),
        ("es", "Español", "🇪🇸")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(languages, id: \.0) { code, name, flag in
                    Button {
                        selectedLanguage = code
                        isPresented = false
                    } label: {
                        HStack {
                            Text(flag)
                                .font(.title2)
                            Text(name)
                                .foregroundStyle(AppConfiguration.textPrimary)
                            Spacer()
                            if selectedLanguage == code {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppConfiguration.primaryBlue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Idioma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    HomeView()
}
