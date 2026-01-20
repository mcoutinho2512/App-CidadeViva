import SwiftUI
import MapKit

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Premium Nav Button

struct PremiumNavButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let colors: [Color]
    let action: () -> Void

    init(icon: String, title: String, subtitle: String? = nil, colors: [Color], action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.colors = colors
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: colors[0].opacity(0.5), radius: 12, y: 6)

                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppConfiguration.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(AppConfiguration.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
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
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppConfiguration.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
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
                        showAlertsFullscreen = true
                    }
                )

                // Conteúdo com scroll
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Banner Hero
                        BannerView()

                        // Botões de navegação premium
                        navigationButtonsSection

                        // Widgets de resumo rápido
                        quickStatsSection

                        // Próximo evento (preview)
                        if let nextEvent = viewModel.events.first {
                            upcomingEventCard(event: nextEvent)
                        }

                        // Alertas recentes (resumo)
                        if !viewModel.alerts.isEmpty {
                            recentAlertsPreview
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
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
        .task {
            await viewModel.loadData()
            updateUnreadAlertsCount()
        }
        .refreshable {
            await viewModel.loadData()
            updateUnreadAlertsCount()
        }
    }

    // MARK: - Navigation Buttons Section

    private var navigationButtonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Explorar")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                PremiumNavButton(
                    icon: "calendar",
                    title: "Eventos",
                    subtitle: "\(viewModel.events.count) próximos",
                    colors: [Color(hex: "FF6B95"), Color(hex: "FF8A65")]
                ) {
                    hapticFeedback()
                    showEventsFullscreen = true
                }

                PremiumNavButton(
                    icon: "bell.fill",
                    title: "Alertas",
                    subtitle: "\(viewModel.alerts.count) ativos",
                    colors: [AppConfiguration.error, Color(hex: "FF6B35")]
                ) {
                    hapticFeedback()
                    showAlertsFullscreen = true
                }

                PremiumNavButton(
                    icon: "video.fill",
                    title: "Câmeras",
                    subtitle: "\(viewModel.cameras.filter { $0.isOnline }.count) online",
                    colors: [Color(hex: "8B5CF6"), AppConfiguration.primaryBlue]
                ) {
                    hapticFeedback()
                    showCamerasFullscreen = true
                }

                PremiumNavButton(
                    icon: "map.fill",
                    title: "Mapa",
                    subtitle: "Pontos de interesse",
                    colors: [AppConfiguration.primaryBlue, Color(hex: "06B6D4")]
                ) {
                    hapticFeedback()
                    showMapFullscreen = true
                }

                PremiumNavButton(
                    icon: "bus.fill",
                    title: "Transporte",
                    subtitle: "Rotas e horários",
                    colors: [AppConfiguration.success, Color(hex: "059669")]
                ) {
                    hapticFeedback()
                    showTransportFullscreen = true
                }

                PremiumNavButton(
                    icon: "ellipsis",
                    title: "Mais",
                    subtitle: "Em breve",
                    colors: [Color.gray, Color.gray.opacity(0.7)]
                ) {
                    // TODO: Menu de mais opções
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppConfiguration.textPrimary)
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                QuickStatCard(
                    icon: "video.fill",
                    value: "\(viewModel.cameras.filter { $0.isOnline }.count)",
                    label: "Câmeras Online",
                    color: AppConfiguration.success
                )

                QuickStatCard(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(viewModel.alerts.count)",
                    label: "Alertas Ativos",
                    color: AppConfiguration.warning
                )

                QuickStatCard(
                    icon: "calendar",
                    value: "\(viewModel.events.count)",
                    label: "Eventos",
                    color: AppConfiguration.primaryBlue
                )
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Upcoming Event Card

    private func upcomingEventCard(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Próximo Evento")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()

                Button("Ver todos") {
                    showEventsFullscreen = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppConfiguration.primaryBlue)
            }
            .padding(.horizontal, 20)

            Button {
                showEventsFullscreen = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B95"), Color(hex: "FF8A65")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)

                        Image(systemName: event.category.iconName)
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppConfiguration.textPrimary)
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
                        .foregroundStyle(AppConfiguration.textSecondary)

                        if event.isFree {
                            Text("Gratuito")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppConfiguration.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppConfiguration.success.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppConfiguration.textTertiary)
                }
                .padding(16)
                .background(AppConfiguration.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Recent Alerts Preview

    private var recentAlertsPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Alertas Recentes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()

                Button("Ver todos") {
                    showAlertsFullscreen = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppConfiguration.primaryBlue)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(viewModel.alerts.prefix(2)) { alert in
                    Button {
                        showAlertsFullscreen = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: alert.severity.iconName)
                                .font(.system(size: 18))
                                .foregroundStyle(alert.severity.color)
                                .frame(width: 40, height: 40)
                                .background(alert.severity.color.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(alert.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppConfiguration.textPrimary)
                                    .lineLimit(1)

                                Text(alert.description)
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppConfiguration.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(alert.createdAt, style: .relative)
                                .font(.system(size: 11))
                                .foregroundStyle(AppConfiguration.textTertiary)
                        }
                        .padding(12)
                        .background(AppConfiguration.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
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

// MARK: - Preview

#Preview {
    HomeView()
}
