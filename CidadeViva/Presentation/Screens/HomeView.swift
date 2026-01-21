import SwiftUI
import MapKit
import Combine

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Institutional Service Card (Estilo Gov.br)

struct InstitutionalServiceCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void

    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Ícone em círculo com borda (estilo institucional)
                ZStack {
                    Circle()
                        .stroke(AppConfiguration.primaryBlue, lineWidth: 2)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppConfiguration.primaryBlue)
                }

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppConfiguration.textPrimary)
                        .multilineTextAlignment(.center)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 10))
                            .foregroundColor(AppConfiguration.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Institutional Stat Card

struct InstitutionalStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppConfiguration.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Institutional Header + Banner Combined

struct InstitutionalHeaderBanner: View {
    let alertCount: Int
    let onAlertsTap: () -> Void
    let onSearchTap: () -> Void

    @State private var banners: [Banner] = []
    @State private var currentBannerIndex = 0
    @State private var isLoadingBanners = true
    private let bannerTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            // Background: Banner do Firebase ou gradiente institucional
            if !banners.isEmpty {
                // Carrossel de banners com imagens
                TabView(selection: $currentBannerIndex) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        BannerImageView(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                // Gradiente institucional como fallback
                LinearGradient(
                    colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87"), Color(hex: "1E3A5F")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Ícone decorativo no banner
                Image(systemName: "building.2.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white.opacity(0.08))
                    .offset(x: 120, y: 180)
            }

            // Overlay gradiente para legibilidade
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Safe area
                Color.clear.frame(height: 50)

                // Header
                HStack(spacing: 12) {
                    // Brasão/Logo
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cidade Viva")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        Text("Prefeitura de Niterói")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    }

                    Spacer()

                    // Ícones de ação
                    HStack(spacing: 16) {
                        Button(action: onSearchTap) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        }

                        Button(action: onAlertsTap) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                                if alertCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Spacer()

                // Banner content (título e subtítulo)
                VStack(alignment: .leading, spacing: 8) {
                    if let currentBanner = banners[safe: currentBannerIndex] {
                        Text(currentBanner.title)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)

                        Text(currentBanner.subtitle)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                    } else {
                        Text("Bem-vindo a Niterói")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)

                        Text("Acesse os serviços da sua cidade")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Indicadores de página (se houver mais de um banner)
                if banners.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<banners.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentBannerIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: index == currentBannerIndex ? 24 : 8, height: 8)
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        }
                    }
                    .padding(.bottom, 16)
                    .animation(.spring(response: 0.3), value: currentBannerIndex)
                }
            }
        }
        .frame(height: 380)
        .clipped()
        .onReceive(bannerTimer) { _ in
            guard banners.count > 1 else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
        .task {
            await loadBanners()
        }
    }

    private func loadBanners() async {
        do {
            let fetchedBanners = try await FirestoreService.shared.fetchBanners()
            print("✅ Banners carregados no Header: \(fetchedBanners.count)")
            await MainActor.run {
                self.banners = fetchedBanners
                self.isLoadingBanners = false
            }
        } catch {
            print("❌ Erro ao carregar banners: \(error)")
            await MainActor.run {
                self.isLoadingBanners = false
            }
        }
    }
}

// MARK: - Banner Image View (para o carrossel)

struct BannerImageView: View {
    let banner: Banner

    var body: some View {
        ZStack {
            // Background gradiente como fallback
            LinearGradient(
                colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Imagem de fundo
            if let imageURL = banner.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        // Fallback: gradiente com ícone
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "1E3A5F"), Color(hex: "2D5A87")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.1))
                        }
                    @unknown default:
                        Color.clear
                    }
                }
            }
        }
    }
}

// MARK: - Safe Array Subscript

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Home View

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showLanguageSelector = false
    @State private var unreadAlertsCount: Int = 0

    // Estados de navegação fullscreen
    @State private var showCamerasFullscreen = false
    @State private var showAlertsFullscreen = false
    @State private var showEventsFullscreen = false
    @State private var showMapFullscreen = false
    @State private var showTransportFullscreen = false
    @State private var showRoutesFullscreen = false

    var body: some View {
        ZStack {
            // Background institucional
            AppConfiguration.backgroundPrimary
                .ignoresSafeArea()

            // Conteúdo com scroll
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header + Banner combinados (sem faixa branca)
                    InstitutionalHeaderBanner(
                        alertCount: unreadAlertsCount,
                        onAlertsTap: { showAlertsFullscreen = true },
                        onSearchTap: { /* TODO: Busca */ }
                    )

                    // Conteúdo principal
                    VStack(spacing: 24) {
                        // Grid de serviços institucional
                        institutionalServicesSection

                        // Cards de estatísticas
                        institutionalStatsSection

                        // Alertas recentes (completo)
                        if !viewModel.alerts.isEmpty {
                            institutionalAlertsSection
                        }

                        // Próximo evento
                        if let nextEvent = viewModel.events.first {
                            institutionalEventCard(event: nextEvent)
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.top, 24)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView(isPresented: $showLanguageSelector)
        }
        // Navegação Fullscreen
        .fullScreenCover(isPresented: $showCamerasFullscreen) {
            CamerasFullScreenView(
                cameras: viewModel.cameras,
                onDismiss: { showCamerasFullscreen = false }
            )
        }
        .fullScreenCover(isPresented: $showAlertsFullscreen) {
            AlertsFullScreenView(
                alerts: viewModel.alerts,
                onDismiss: {
                    showAlertsFullscreen = false
                    withAnimation {
                        unreadAlertsCount = 0
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showEventsFullscreen) {
            EventsFullScreenView(
                events: viewModel.events,
                onDismiss: { showEventsFullscreen = false }
            )
        }
        .fullScreenCover(isPresented: $showMapFullscreen) {
            MapFullScreenView(
                pointsOfInterest: viewModel.pointsOfInterest,
                onDismiss: { showMapFullscreen = false }
            )
        }
        .fullScreenCover(isPresented: $showTransportFullscreen) {
            TransportFullScreenView(
                onDismiss: { showTransportFullscreen = false }
            )
        }
        .fullScreenCover(isPresented: $showRoutesFullscreen) {
            RoutesFullScreenView(
                onDismiss: { showRoutesFullscreen = false }
            )
        }
        .task {
            await viewModel.loadData()
            updateUnreadAlertsCount()
        }
        .refreshable {
            await viewModel.loadData()
            updateUnreadAlertsCount()
        }
    }

    // MARK: - Institutional Services Section (Grid 3x2)

    private var institutionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Serviços")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InstitutionalServiceCard(
                    icon: "calendar",
                    title: "Eventos",
                    subtitle: "\(viewModel.events.count) próximos"
                ) {
                    hapticFeedback()
                    showEventsFullscreen = true
                }

                InstitutionalServiceCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Alertas",
                    subtitle: "\(viewModel.alerts.count) ativos"
                ) {
                    hapticFeedback()
                    showAlertsFullscreen = true
                }

                InstitutionalServiceCard(
                    icon: "video.fill",
                    title: "Câmeras",
                    subtitle: "\(viewModel.cameras.filter { $0.isOnline }.count) online"
                ) {
                    hapticFeedback()
                    showCamerasFullscreen = true
                }

                InstitutionalServiceCard(
                    icon: "map.fill",
                    title: "Mapa",
                    subtitle: "Pontos de interesse"
                ) {
                    hapticFeedback()
                    showMapFullscreen = true
                }

                InstitutionalServiceCard(
                    icon: "bus.fill",
                    title: "Transporte",
                    subtitle: "Rotas e horários"
                ) {
                    hapticFeedback()
                    showTransportFullscreen = true
                }

                InstitutionalServiceCard(
                    icon: "arrow.triangle.turn.up.right.diamond.fill",
                    title: "Rotas",
                    subtitle: "Navegação GPS"
                ) {
                    hapticFeedback()
                    showRoutesFullscreen = true
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Institutional Stats Section

    private var institutionalStatsSection: some View {
        HStack(spacing: 12) {
            InstitutionalStatCard(
                icon: "video.fill",
                value: "\(viewModel.cameras.filter { $0.isOnline }.count)",
                label: "Câmeras",
                color: AppConfiguration.success
            )

            InstitutionalStatCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(viewModel.alerts.count)",
                label: "Alertas",
                color: AppConfiguration.warning
            )

            InstitutionalStatCard(
                icon: "calendar",
                value: "\(viewModel.events.count)",
                label: "Eventos",
                color: AppConfiguration.primaryBlue
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Institutional Alerts Section

    private var institutionalAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header da seção
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppConfiguration.warning)
                    Text("Alertas Recentes")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppConfiguration.textPrimary)
                }

                Spacer()

                Button("Ver todos") {
                    showAlertsFullscreen = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppConfiguration.primaryBlue)
            }
            .padding(.horizontal, 20)

            // Lista de alertas
            VStack(spacing: 12) {
                ForEach(viewModel.alerts.prefix(3)) { alert in
                    Button {
                        showAlertsFullscreen = true
                    } label: {
                        HStack(spacing: 12) {
                            // Indicador de severidade
                            Circle()
                                .fill(alert.severity.color)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(alert.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppConfiguration.textPrimary)
                                    .lineLimit(1)

                                Text(alert.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppConfiguration.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(alert.createdAt, style: .relative)
                                .font(.system(size: 12))
                                .foregroundColor(AppConfiguration.textSecondary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppConfiguration.textSecondary)
                        }
                        .padding(16)
                        .background(AppConfiguration.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Institutional Event Card

    private func institutionalEventCard(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Próximo Evento")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppConfiguration.textPrimary)

                Spacer()

                Button("Ver todos") {
                    showEventsFullscreen = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppConfiguration.primaryBlue)
            }
            .padding(.horizontal, 20)

            Button {
                showEventsFullscreen = true
            } label: {
                HStack(spacing: 16) {
                    // Ícone institucional
                    ZStack {
                        Circle()
                            .stroke(AppConfiguration.primaryBlue, lineWidth: 2)
                            .frame(width: 56, height: 56)

                        Image(systemName: event.category.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(AppConfiguration.primaryBlue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppConfiguration.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Label {
                                Text(event.startDate, style: .date)
                            } icon: {
                                Image(systemName: "calendar")
                            }

                            Label {
                                Text(event.startDate, style: .time)
                            } icon: {
                                Image(systemName: "clock")
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundColor(AppConfiguration.textSecondary)

                        if event.isFree {
                            Text("Gratuito")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppConfiguration.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppConfiguration.success.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppConfiguration.textSecondary)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Helpers

    private func updateUnreadAlertsCount() {
        unreadAlertsCount = viewModel.alerts.count
    }

    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
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

// MARK: - Cameras Full Screen View

struct CamerasFullScreenView: View {
    let cameras: [Camera]
    let onDismiss: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var selectedCamera: Camera?
    @State private var showFilters = false
    @State private var showOnlyOnline = false

    private let headerColors: [Color] = [Color(hex: "8B5CF6"), AppConfiguration.primaryBlue]

    init(cameras: [Camera], onDismiss: @escaping () -> Void) {
        self.cameras = cameras
        self.onDismiss = onDismiss
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -22.8839, longitude: -43.1034),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    private var filteredCameras: [Camera] {
        showOnlyOnline ? cameras.filter { $0.isOnline } : cameras
    }

    private var onlineCamerasCount: Int {
        cameras.filter { $0.isOnline }.count
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: filteredCameras) { camera in
                MapAnnotation(coordinate: camera.coordinate) {
                    CameraMapPin(
                        camera: camera,
                        isSelected: selectedCamera?.id == camera.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCamera = camera
                                region.center = camera.coordinate
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                camerasHeader
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        cameraMapControlButton(icon: "line.3.horizontal.decrease.circle") {
                            withAnimation { showFilters.toggle() }
                        }
                        cameraMapControlButton(icon: "location.fill") { fitAllCameras() }
                        Divider().frame(width: 30)
                        cameraMapControlButton(icon: "plus") { zoomIn() }
                        cameraMapControlButton(icon: "minus") { zoomOut() }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    .padding(.trailing, 16)
                    .padding(.bottom, selectedCamera != nil ? 220 : 100)
                }

                if let camera = selectedCamera {
                    cameraInfoCard(camera: camera)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                cameraLegendView.padding(.bottom, 16)
            }

            if showFilters { cameraFiltersOverlay }
        }
        .onAppear { fitAllCameras() }
    }

    private var camerasHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Câmeras")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(onlineCamerasCount) online de \(cameras.count)")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private func cameraMapControlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var cameraLegendView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                Text("Online").font(.system(size: 12))
            }
            HStack(spacing: 6) {
                Circle().fill(Color.red).frame(width: 10, height: 10)
                Text("Offline").font(.system(size: 12))
            }
            Spacer()
            Text("\(filteredCameras.count) câmeras")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func cameraInfoCard(camera: Camera) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(camera.isOnline ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "video.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(camera.isOnline ? .green : .red)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                HStack(spacing: 6) {
                    Circle().fill(camera.isOnline ? Color.green : Color.red).frame(width: 8, height: 8)
                    Text(camera.isOnline ? "Online" : "Offline")
                        .font(.system(size: 13))
                        .foregroundStyle(camera.isOnline ? .green : .red)
                    if let neighborhood = camera.location.neighborhood {
                        Text("•").foregroundStyle(AppConfiguration.textTertiary)
                        Text(neighborhood)
                            .font(.system(size: 13))
                            .foregroundStyle(AppConfiguration.textSecondary)
                    }
                }
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3)) { selectedCamera = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppConfiguration.textTertiary)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var cameraFiltersOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { withAnimation { showFilters = false } }
            VStack(spacing: 16) {
                Text("Filtros").font(.system(size: 18, weight: .bold))
                Toggle("Mostrar apenas online", isOn: $showOnlyOnline).tint(AppConfiguration.success)
                Button("Aplicar") { withAnimation { showFilters = false } }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppConfiguration.primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
            .background(AppConfiguration.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(.horizontal, 40)
        }
    }

    private func fitAllCameras() {
        guard !filteredCameras.isEmpty else { return }
        let latitudes = filteredCameras.map { $0.location.latitude }
        let longitudes = filteredCameras.map { $0.location.longitude }
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) * 1.5, 0.05), longitudeDelta: max((maxLon - minLon) * 1.5, 0.05))
        withAnimation(.easeInOut(duration: 0.5)) { region = MKCoordinateRegion(center: center, span: span) }
    }

    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = max(region.span.latitudeDelta / 2, 0.005)
            region.span.longitudeDelta = max(region.span.longitudeDelta / 2, 0.005)
        }
    }

    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 1.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 1.0)
        }
    }
}

// MARK: - Alerts Full Screen View

struct AlertsFullScreenView: View {
    let alerts: [Alert]
    let onDismiss: () -> Void

    @State private var selectedSeverity: Alert.Severity?

    private let headerColors: [Color] = [AppConfiguration.error, Color(hex: "FF6B35")]

    private var filteredAlerts: [Alert] {
        if let severity = selectedSeverity {
            return alerts.filter { $0.severity == severity }
        }
        return alerts
    }

    private var criticalAlerts: [Alert] { filteredAlerts.filter { $0.severity == .critical } }
    private var otherAlerts: [Alert] { filteredAlerts.filter { $0.severity != .critical } }

    var body: some View {
        ZStack {
            AppConfiguration.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                alertsHeader
                alertsFilterChips

                if filteredAlerts.isEmpty {
                    alertsEmptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if !criticalAlerts.isEmpty {
                                alertsSection(title: "Alertas Críticos", alerts: criticalAlerts, isCritical: true)
                            }
                            if !otherAlerts.isEmpty {
                                alertsSection(title: "Outros Alertas", alerts: otherAlerts, isCritical: false)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    private var alertsHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alertas")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(alerts.count) alertas ativos")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var alertsFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                alertFilterChip(title: "Todos", isActive: selectedSeverity == nil, color: AppConfiguration.primaryBlue) {
                    withAnimation { selectedSeverity = nil }
                }
                ForEach(Alert.Severity.allCases, id: \.self) { severity in
                    alertFilterChip(title: severity.rawValue, icon: severity.iconName, isActive: selectedSeverity == severity, color: severity.color) {
                        withAnimation { selectedSeverity = selectedSeverity == severity ? nil : severity }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(AppConfiguration.backgroundCard)
    }

    private func alertFilterChip(title: String, icon: String? = nil, isActive: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon).font(.system(size: 10, weight: .bold))
                }
                Text(title).font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(isActive ? color.opacity(0.15) : Color.gray.opacity(0.1)))
            .foregroundStyle(isActive ? color : .secondary)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func alertsSection(title: String, alerts: [Alert], isCritical: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isCritical {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isCritical ? .red : AppConfiguration.textPrimary)
                Spacer()
                Text("\(alerts.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isCritical ? Color.red : AppConfiguration.primaryBlue)
                    .clipShape(Capsule())
            }
            ForEach(alerts) { alert in
                alertCard(alert: alert)
            }
        }
    }

    private func alertCard(alert: Alert) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(alert.severity.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: alert.severity.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(alert.severity.color)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(alert.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppConfiguration.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(alert.severity.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(alert.severity.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(alert.severity.color.opacity(0.15))
                        .clipShape(Capsule())
                }
                Text(alert.description)
                    .font(.system(size: 13))
                    .foregroundStyle(AppConfiguration.textSecondary)
                    .lineLimit(2)
                HStack {
                    Label(alert.category.rawValue, systemImage: "tag")
                    Spacer()
                    Text(alert.createdAt, style: .relative)
                }
                .font(.system(size: 11))
                .foregroundStyle(AppConfiguration.textTertiary)
            }
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var alertsEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(AppConfiguration.success.opacity(0.1)).frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle").font(.system(size: 48)).foregroundStyle(AppConfiguration.success)
            }
            VStack(spacing: 8) {
                Text("Tudo tranquilo!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                Text(selectedSeverity != nil ? "Não há alertas com essa severidade." : "Não há alertas ativos no momento.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppConfiguration.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if selectedSeverity != nil {
                Button("Ver todos") { withAnimation { selectedSeverity = nil } }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConfiguration.primaryBlue)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Events Full Screen View

struct EventsFullScreenView: View {
    let events: [Event]
    let onDismiss: () -> Void

    @State private var selectedCategory: Event.Category?

    private let headerColors: [Color] = [Color(hex: "FF6B95"), Color(hex: "FF8A65")]

    private var filteredEvents: [Event] {
        if let category = selectedCategory {
            return events.filter { $0.category == category }
        }
        return events
    }

    var body: some View {
        ZStack {
            AppConfiguration.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                eventsHeader
                eventsCategoryFilters

                if filteredEvents.isEmpty {
                    eventsEmptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                eventCard(event: event)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    private var eventsHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Eventos")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(events.count) eventos disponíveis")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var eventsCategoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                eventFilterChip(title: "Todos", icon: "square.grid.2x2", isActive: selectedCategory == nil) {
                    withAnimation { selectedCategory = nil }
                }
                ForEach(Event.Category.allCases, id: \.self) { category in
                    eventFilterChip(title: category.rawValue, icon: category.iconName, isActive: selectedCategory == category) {
                        withAnimation { selectedCategory = selectedCategory == category ? nil : category }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(AppConfiguration.backgroundCard)
    }

    private func eventFilterChip(title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(title).font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(isActive ? AppConfiguration.primaryBlue.opacity(0.15) : Color.gray.opacity(0.1)))
            .foregroundStyle(isActive ? AppConfiguration.primaryBlue : .secondary)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func eventCard(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(event.category.rawValue, systemImage: event.category.iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppConfiguration.primaryBlue)
                Spacer()
                if event.isFree {
                    Text("Gratuito")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppConfiguration.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppConfiguration.success.opacity(0.15))
                        .clipShape(Capsule())
                } else if let price = event.price {
                    Text("R$ \(String(format: "%.0f", price))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppConfiguration.textSecondary)
                }
            }
            Text(event.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)
                .lineLimit(2)
            Text(event.description)
                .font(.system(size: 13))
                .foregroundStyle(AppConfiguration.textSecondary)
                .lineLimit(2)
            HStack(spacing: 16) {
                Label { Text(event.startDate, style: .date) } icon: { Image(systemName: "calendar") }
                Label { Text(event.startDate, style: .time) } icon: { Image(systemName: "clock") }
            }
            .font(.system(size: 12))
            .foregroundStyle(AppConfiguration.textSecondary)
            if let address = event.location.address {
                Label(address, systemImage: "mappin")
                    .font(.system(size: 12))
                    .foregroundStyle(AppConfiguration.textTertiary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    private var eventsEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(AppConfiguration.primaryBlue.opacity(0.1)).frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.exclamationmark").font(.system(size: 48)).foregroundStyle(AppConfiguration.primaryBlue)
            }
            VStack(spacing: 8) {
                Text("Nenhum evento")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                Text(selectedCategory != nil ? "Não há eventos nesta categoria." : "Não há eventos disponíveis no momento.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppConfiguration.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if selectedCategory != nil {
                Button("Ver todos") { withAnimation { selectedCategory = nil } }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConfiguration.primaryBlue)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Map Full Screen View

struct MapFullScreenView: View {
    let pointsOfInterest: [PointOfInterest]
    let onDismiss: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var selectedPOI: PointOfInterest?

    private let headerColors: [Color] = [AppConfiguration.primaryBlue, Color(hex: "06B6D4")]

    init(pointsOfInterest: [PointOfInterest], onDismiss: @escaping () -> Void) {
        self.pointsOfInterest = pointsOfInterest
        self.onDismiss = onDismiss
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -22.8839, longitude: -43.1034),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: pointsOfInterest) { poi in
                MapAnnotation(coordinate: poi.location.coordinate) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPOI = poi
                            region.center = poi.location.coordinate
                        }
                    } label: {
                        Image(systemName: poi.category.iconName)
                            .font(.system(size: selectedPOI?.id == poi.id ? 16 : 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: selectedPOI?.id == poi.id ? 44 : 36, height: selectedPOI?.id == poi.id ? 44 : 36)
                            .background(AppConfiguration.primaryBlue)
                            .clipShape(Circle())
                            .shadow(color: AppConfiguration.primaryBlue.opacity(0.4), radius: selectedPOI?.id == poi.id ? 8 : 4)
                    }
                    .scaleEffect(selectedPOI?.id == poi.id ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedPOI?.id)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                mapHeader
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        mapControlBtn(icon: "location.fill") { fitAllPOIs() }
                        Divider().frame(width: 30)
                        mapControlBtn(icon: "plus") { mapZoomIn() }
                        mapControlBtn(icon: "minus") { mapZoomOut() }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    .padding(.trailing, 16)
                    .padding(.bottom, selectedPOI != nil ? 180 : 80)
                }
                if let poi = selectedPOI {
                    poiCard(poi: poi)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear { fitAllPOIs() }
    }

    private var mapHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mapa")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(pointsOfInterest.count) pontos de interesse")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private func mapControlBtn(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func poiCard(poi: PointOfInterest) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppConfiguration.primaryBlue.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: poi.category.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(AppConfiguration.primaryBlue)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                HStack(spacing: 8) {
                    Text(poi.category.rawValue)
                        .font(.system(size: 13))
                        .foregroundStyle(AppConfiguration.textSecondary)
                    if let rating = poi.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating)).font(.system(size: 12, weight: .medium))
                        }
                    }
                }
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3)) { selectedPOI = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppConfiguration.textTertiary)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func fitAllPOIs() {
        guard !pointsOfInterest.isEmpty else { return }
        let latitudes = pointsOfInterest.map { $0.location.latitude }
        let longitudes = pointsOfInterest.map { $0.location.longitude }
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) * 1.5, 0.05), longitudeDelta: max((maxLon - minLon) * 1.5, 0.05))
        withAnimation(.easeInOut(duration: 0.5)) { region = MKCoordinateRegion(center: center, span: span) }
    }

    private func mapZoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = max(region.span.latitudeDelta / 2, 0.005)
            region.span.longitudeDelta = max(region.span.longitudeDelta / 2, 0.005)
        }
    }

    private func mapZoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 1.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 1.0)
        }
    }
}

// MARK: - Transport Full Screen View

struct TransportFullScreenView: View {
    let onDismiss: () -> Void

    @State private var selectedMode: TransportModeType = .bus

    private let headerColors: [Color] = [AppConfiguration.success, Color(hex: "059669")]

    var body: some View {
        ZStack {
            AppConfiguration.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                transportHeader
                transportModeSelector

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch selectedMode {
                        case .bus: busContent
                        case .ferry: ferryContent
                        case .bike: bikeContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private var transportHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "bus.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transporte")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Rotas e horários")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var transportModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TransportModeType.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedMode = mode }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: mode.icon).font(.system(size: 20, weight: .semibold))
                        Text(mode.title).font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(selectedMode == mode ? AppConfiguration.success : AppConfiguration.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedMode == mode ? AppConfiguration.success.opacity(0.1) : Color.clear)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .background(AppConfiguration.backgroundCard)
    }

    private var busContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Linhas Populares").font(.system(size: 18, weight: .bold)).foregroundStyle(AppConfiguration.textPrimary)
                busLineCard(number: "47", name: "Centro ↔ Icaraí", frequency: "10 min")
                busLineCard(number: "33", name: "Centro ↔ Charitas", frequency: "15 min")
                busLineCard(number: "38", name: "Centro ↔ São Francisco", frequency: "12 min")
            }
            transportInfoCard(icon: "info.circle", title: "Horários", description: "Os horários podem variar. Consulte o aplicativo da empresa de transporte.")
        }
    }

    private var ferryContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Estações de Barcas").font(.system(size: 18, weight: .bold)).foregroundStyle(AppConfiguration.textPrimary)
                ferryStationCard(name: "Arariboia", location: "Centro", nextDeparture: "15:30")
                ferryStationCard(name: "Charitas", location: "Charitas", nextDeparture: "16:00")
            }
            transportInfoCard(icon: "clock", title: "Próximas Partidas", description: "Niterói → Rio: 15min\nRio → Niterói: 20min")
        }
    }

    private var bikeContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Estações BikeRio").font(.system(size: 18, weight: .bold)).foregroundStyle(AppConfiguration.textPrimary)
                bikeStationCard(name: "Praça Arariboia", availableBikes: 5, availableSlots: 10)
                bikeStationCard(name: "Campo de São Bento", availableBikes: 8, availableSlots: 7)
                bikeStationCard(name: "Praia de Icaraí", availableBikes: 3, availableSlots: 12)
            }
            transportInfoCard(icon: "questionmark.circle", title: "Como usar", description: "Baixe o app BikeRio, cadastre-se e retire a bike. A primeira hora é gratuita!")
        }
    }

    private func busLineCard(number: String, name: String, frequency: String) -> some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(AppConfiguration.success)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppConfiguration.textPrimary)
                Text("A cada \(frequency)").font(.system(size: 13)).foregroundStyle(AppConfiguration.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(AppConfiguration.textTertiary)
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func ferryStationCard(name: String, location: String, nextDeparture: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "ferry.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(AppConfiguration.primaryBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text("Estação \(name)").font(.system(size: 15, weight: .semibold)).foregroundStyle(AppConfiguration.textPrimary)
                Text(location).font(.system(size: 13)).foregroundStyle(AppConfiguration.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Próxima").font(.system(size: 11)).foregroundStyle(AppConfiguration.textTertiary)
                Text(nextDeparture).font(.system(size: 15, weight: .bold)).foregroundStyle(AppConfiguration.success)
            }
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func bikeStationCard(name: String, availableBikes: Int, availableSlots: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "bicycle")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppConfiguration.textPrimary)
                HStack(spacing: 12) {
                    Label("\(availableBikes) bikes", systemImage: "bicycle")
                    Label("\(availableSlots) vagas", systemImage: "parkingsign")
                }
                .font(.system(size: 12))
                .foregroundStyle(AppConfiguration.textSecondary)
            }
            Spacer()
            Circle().fill(availableBikes > 0 ? AppConfiguration.success : AppConfiguration.error).frame(width: 12, height: 12)
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func transportInfoCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppConfiguration.primaryBlue)
                .frame(width: 40, height: 40)
                .background(AppConfiguration.primaryBlue.opacity(0.1))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppConfiguration.textPrimary)
                Text(description).font(.system(size: 13)).foregroundStyle(AppConfiguration.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private enum TransportModeType: CaseIterable {
    case bus, ferry, bike

    var title: String {
        switch self {
        case .bus: return "Ônibus"
        case .ferry: return "Barcas"
        case .bike: return "Bicicleta"
        }
    }

    var icon: String {
        switch self {
        case .bus: return "bus.fill"
        case .ferry: return "ferry.fill"
        case .bike: return "bicycle"
        }
    }
}

// MARK: - Routes Full Screen View

/// Modelo para destinos de rota
struct RouteDestination: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: RouteCategory
    let coordinate: CLLocationCoordinate2D
    let address: String?

    static func == (lhs: RouteDestination, rhs: RouteDestination) -> Bool {
        lhs.id == rhs.id
    }
}

/// Categorias de POIs para rotas
enum RouteCategory: String, CaseIterable {
    case ferry = "Barcas"
    case hospital = "Hospitais"
    case theater = "Teatros"
    case beach = "Praias"

    var icon: String {
        switch self {
        case .ferry: return "ferry.fill"
        case .hospital: return "cross.fill"
        case .theater: return "theatermasks.fill"
        case .beach: return "beach.umbrella.fill"
        }
    }

    var color: Color {
        switch self {
        case .ferry: return AppConfiguration.primaryBlue
        case .hospital: return AppConfiguration.error
        case .theater: return Color(hex: "8B5CF6")
        case .beach: return Color(hex: "06B6D4")
        }
    }
}

/// Modo de transporte para rota
enum RouteTransportMode: String, CaseIterable {
    case automobile = "Carro"
    case walking = "A pé"
    case transit = "Transporte"

    var icon: String {
        switch self {
        case .automobile: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        }
    }

    var mkTransportType: MKDirectionsTransportType {
        switch self {
        case .automobile: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        }
    }
}

/// LocationManager para obter localização real do usuário
class RouteLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startUpdating()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.startUpdating()
            }
        }
    }
}

/// UIViewRepresentable para mostrar o mapa com polyline da rota
struct RouteMapView: UIViewRepresentable {
    let region: MKCoordinateRegion
    let destinations: [RouteDestination]
    let selectedDestination: RouteDestination?
    let routePolyline: MKPolyline?
    let userLocation: CLLocationCoordinate2D?
    let onDestinationTap: (RouteDestination) -> Void
    let onRegionChange: (MKCoordinateRegion) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false // Desabilitar para não interferir
        mapView.userTrackingMode = .none // Não seguir usuário
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Sempre atualizar a região para garantir que mostre Niterói
        mapView.setRegion(region, animated: true)

        // Remover anotações antigas (exceto localização do usuário)
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        // Adicionar anotações dos destinos
        for destination in destinations {
            let annotation = RouteAnnotation(destination: destination)
            annotation.coordinate = destination.coordinate
            annotation.title = destination.name
            mapView.addAnnotation(annotation)
        }

        // Remover overlays antigos
        mapView.removeOverlays(mapView.overlays)

        // Adicionar polyline da rota se existir
        if let polyline = routePolyline {
            mapView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView

        init(_ parent: RouteMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Não customizar a localização do usuário
            if annotation is MKUserLocation {
                return nil
            }

            guard let routeAnnotation = annotation as? RouteAnnotation else { return nil }

            let identifier = "RouteDestination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: routeAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = routeAnnotation
            }

            let category = routeAnnotation.destination.category
            annotationView?.markerTintColor = UIColor(category.color)
            annotationView?.glyphImage = UIImage(systemName: category.icon)

            // Destaque se selecionado
            if parent.selectedDestination?.id == routeAnnotation.destination.id {
                annotationView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } else {
                annotationView?.transform = .identity
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let routeAnnotation = annotation as? RouteAnnotation else { return }
            parent.onDestinationTap(routeAnnotation.destination)
            mapView.deselectAnnotation(annotation, animated: true)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(AppConfiguration.primaryBlue)
                renderer.lineWidth = 6
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            // Atualizar região no parent
        }
    }
}

/// Anotação customizada para destinos
class RouteAnnotation: NSObject, MKAnnotation {
    let destination: RouteDestination
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?

    init(destination: RouteDestination) {
        self.destination = destination
        self.coordinate = destination.coordinate
        self.title = destination.name
    }
}

/// Tela fullscreen de rotas com navegação
struct RoutesFullScreenView: View {
    let onDismiss: () -> Void

    @StateObject private var locationManager = RouteLocationManager()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -22.8839, longitude: -43.1034),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    @State private var selectedCategory: RouteCategory?
    @State private var selectedDestination: RouteDestination?
    @State private var selectedTransportMode: RouteTransportMode = .automobile
    @State private var routePolyline: MKPolyline?
    @State private var routeDistance: CLLocationDistance = 0
    @State private var routeTime: TimeInterval = 0
    @State private var isCalculatingRoute = false
    @State private var hasRouteInfo = false

    private let headerColors: [Color] = [Color(hex: "6366F1"), Color(hex: "8B5CF6")]

    // POIs fornecidos pelo usuário
    private let allDestinations: [RouteDestination] = [
        // Barcas
        RouteDestination(name: "Estação Arariboia", category: .ferry, coordinate: CLLocationCoordinate2D(latitude: -22.8939, longitude: -43.1245), address: "Centro, Niterói"),

        // Hospitais
        RouteDestination(name: "Hospital Icaraí", category: .hospital, coordinate: CLLocationCoordinate2D(latitude: -22.9023, longitude: -43.1098), address: "Icaraí, Niterói"),
        RouteDestination(name: "UPA Centro", category: .hospital, coordinate: CLLocationCoordinate2D(latitude: -22.8912, longitude: -43.1267), address: "Centro, Niterói"),

        // Teatros
        RouteDestination(name: "Teatro Municipal", category: .theater, coordinate: CLLocationCoordinate2D(latitude: -22.8967, longitude: -43.1189), address: "Centro, Niterói"),
        RouteDestination(name: "Teatro Popular", category: .theater, coordinate: CLLocationCoordinate2D(latitude: -22.8934, longitude: -43.1234), address: "Centro, Niterói"),

        // Praias
        RouteDestination(name: "Praia de Icaraí", category: .beach, coordinate: CLLocationCoordinate2D(latitude: -22.9042, longitude: -43.1087), address: "Icaraí, Niterói"),
        RouteDestination(name: "Praia de São Francisco", category: .beach, coordinate: CLLocationCoordinate2D(latitude: -22.9156, longitude: -43.0934), address: "São Francisco, Niterói")
    ]

    private var filteredDestinations: [RouteDestination] {
        if let category = selectedCategory {
            return allDestinations.filter { $0.category == category }
        }
        return allDestinations
    }

    var body: some View {
        ZStack {
            // Mapa com rota
            RouteMapView(
                region: region,
                destinations: filteredDestinations,
                selectedDestination: selectedDestination,
                routePolyline: routePolyline,
                userLocation: locationManager.userLocation,
                onDestinationTap: { destination in
                    selectDestination(destination)
                },
                onRegionChange: { newRegion in
                    // Atualizar região se necessário
                }
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                routesHeader

                // Chips de categoria
                categoryChips

                // Lista de destinos (quando nenhum selecionado)
                if selectedDestination == nil {
                    destinationsList
                }

                Spacer()

                // Controles do mapa
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        routeMapControlButton(icon: "location.fill") {
                            centerOnUserLocation()
                        }
                        routeMapControlButton(icon: "mappin.circle.fill") {
                            // Centralizar nos destinos (Niterói)
                            fitAllDestinations()
                        }
                        Divider().frame(width: 30)
                        routeMapControlButton(icon: "plus") { zoomIn() }
                        routeMapControlButton(icon: "minus") { zoomOut() }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    .padding(.trailing, 16)
                    .padding(.bottom, selectedDestination != nil ? 320 : 20)
                }

                // Card de destino selecionado
                if let destination = selectedDestination {
                    routeDetailsCard(destination: destination)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            // Centralizar em Niterói ao abrir
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -22.8939, longitude: -43.1145),
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
        }
    }

    // MARK: - Header

    private var routesHeader: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 50)
            HStack(spacing: 16) {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())

                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rotas")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Navegue até seu destino")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(LinearGradient(colors: headerColors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "Todos", icon: "square.grid.2x2", isActive: selectedCategory == nil, color: AppConfiguration.primaryBlue) {
                    withAnimation {
                        selectedCategory = nil
                        selectedDestination = nil
                        routePolyline = nil
                    }
                }

                ForEach(RouteCategory.allCases, id: \.self) { category in
                    categoryChip(title: category.rawValue, icon: category.icon, isActive: selectedCategory == category, color: category.color) {
                        withAnimation {
                            selectedCategory = selectedCategory == category ? nil : category
                            selectedDestination = nil
                            routePolyline = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    private func categoryChip(title: String, icon: String, isActive: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                Text(title).font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(isActive ? color.opacity(0.2) : Color.gray.opacity(0.1)))
            .foregroundStyle(isActive ? color : .secondary)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Destinations List

    private var destinationsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filteredDestinations) { destination in
                    Button {
                        selectDestination(destination)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: destination.category.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(destination.category.color)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(destination.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppConfiguration.textPrimary)
                                    .lineLimit(1)

                                if let address = destination.address {
                                    Text(address)
                                        .font(.system(size: 11))
                                        .foregroundStyle(AppConfiguration.textSecondary)
                                        .lineLimit(1)
                                }
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppConfiguration.textTertiary)
                        }
                        .padding(10)
                        .background(AppConfiguration.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Route Details Card

    private func routeDetailsCard(destination: RouteDestination) -> some View {
        VStack(spacing: 0) {
            // Seletor de modo de transporte
            HStack(spacing: 0) {
                ForEach(RouteTransportMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTransportMode = mode
                            calculateRoute(to: destination)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 18, weight: .semibold))
                            Text(mode.rawValue)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(selectedTransportMode == mode ? AppConfiguration.primaryBlue : AppConfiguration.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTransportMode == mode ? AppConfiguration.primaryBlue.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .background(AppConfiguration.backgroundCard)

            Divider()

            // Detalhes do destino
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(destination.category.color.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: destination.category.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(destination.category.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(destination.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppConfiguration.textPrimary)

                        if let address = destination.address {
                            Label(address, systemImage: "mappin")
                                .font(.system(size: 13))
                                .foregroundStyle(AppConfiguration.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDestination = nil
                            routePolyline = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppConfiguration.textTertiary)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }

                // Informações da rota
                if hasRouteInfo {
                    HStack(spacing: 20) {
                        VStack(spacing: 2) {
                            Text(formatDistance(routeDistance))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppConfiguration.textPrimary)
                            Text("Distância")
                                .font(.system(size: 11))
                                .foregroundStyle(AppConfiguration.textSecondary)
                        }

                        Divider().frame(height: 40)

                        VStack(spacing: 2) {
                            Text(formatTime(routeTime))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppConfiguration.primaryBlue)
                            Text("Tempo estimado")
                                .font(.system(size: 11))
                                .foregroundStyle(AppConfiguration.textSecondary)
                        }

                        Divider().frame(height: 40)

                        VStack(spacing: 2) {
                            Image(systemName: selectedTransportMode.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(AppConfiguration.success)
                            Text(selectedTransportMode.rawValue)
                                .font(.system(size: 11))
                                .foregroundStyle(AppConfiguration.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)

                    // Indicador de rota no mapa
                    if routePolyline != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppConfiguration.success)
                            Text("Rota traçada no mapa")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppConfiguration.success)
                        }
                        .padding(.vertical, 6)
                    }
                } else if isCalculatingRoute {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Calculando rota...")
                            .font(.system(size: 13))
                            .foregroundStyle(AppConfiguration.textSecondary)
                    }
                    .padding(.vertical, 12)
                }

                // Botão Iniciar Navegação (abre Apple Maps)
                Button {
                    openInMaps(destination: destination)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Iniciar Navegação")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppConfiguration.success, Color(hex: "059669")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(16)
            .background(AppConfiguration.backgroundCard)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
    }

    // MARK: - Map Controls

    private func routeMapControlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions

    private func selectDestination(_ destination: RouteDestination) {
        withAnimation(.spring(response: 0.3)) {
            selectedDestination = destination
            region.center = destination.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }
        calculateRoute(to: destination)
    }

    private func calculateRoute(to destination: RouteDestination) {
        isCalculatingRoute = true
        routePolyline = nil
        hasRouteInfo = false

        // Usar sempre localização simulada em Niterói (Praça Arariboia) como origem
        // Isso garante que as rotas funcionem mesmo com o simulador em outro país
        let originCoordinate = CLLocationCoordinate2D(latitude: -22.8939, longitude: -43.1245)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: originCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = selectedTransportMode.mkTransportType

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            DispatchQueue.main.async {
                isCalculatingRoute = false

                if let route = response?.routes.first {
                    routePolyline = route.polyline
                    routeDistance = route.distance
                    routeTime = route.expectedTravelTime
                    hasRouteInfo = true

                    // Ajustar região para mostrar toda a rota (origem + destino)
                    let rect = route.polyline.boundingMapRect
                    withAnimation(.easeInOut(duration: 0.5)) {
                        region = MKCoordinateRegion(rect.insetBy(dx: -rect.width * 0.3, dy: -rect.height * 0.3))
                    }
                } else {
                    // Fallback: calcular distância em linha reta
                    let origin = CLLocation(latitude: originCoordinate.latitude, longitude: originCoordinate.longitude)
                    let dest = CLLocation(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
                    routeDistance = origin.distance(from: dest)

                    // Estimar tempo baseado no modo de transporte
                    switch selectedTransportMode {
                    case .automobile:
                        routeTime = routeDistance / 8.33 // ~30 km/h em cidade
                    case .walking:
                        routeTime = routeDistance / 1.39 // ~5 km/h
                    case .transit:
                        routeTime = routeDistance / 5.56 // ~20 km/h
                    }

                    hasRouteInfo = true

                    // Centralizar no destino já que não temos polyline
                    withAnimation(.easeInOut(duration: 0.5)) {
                        region.center = destination.coordinate
                        region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    }
                }
            }
        }
    }

    private func openInMaps(destination: RouteDestination) {
        let placemark = MKPlacemark(coordinate: destination.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destination.name

        let launchOptions: [String: Any]
        switch selectedTransportMode {
        case .automobile:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        case .walking:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        case .transit:
            launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        }

        mapItem.openInMaps(launchOptions: launchOptions)
    }

    private func centerOnUserLocation() {
        if let location = locationManager.userLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location
                region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            }
        } else {
            // Centralizar em Niterói
            fitAllDestinations()
        }
    }

    private func fitAllDestinations() {
        guard !filteredDestinations.isEmpty else { return }

        let latitudes = filteredDestinations.map { $0.coordinate.latitude }
        let longitudes = filteredDestinations.map { $0.coordinate.longitude }

        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.03),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.03)
        )

        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }

    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = max(region.span.latitudeDelta / 2, 0.005)
            region.span.longitudeDelta = max(region.span.longitudeDelta / 2, 0.005)
        }
    }

    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 1.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 1.0)
        }
    }

    // MARK: - Formatters

    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)min"
        } else {
            return "\(minutes) min"
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
