import SwiftUI

/// Modo de visualização das câmeras
enum CamerasViewMode: String, CaseIterable {
    case list = "Lista"
    case map = "Mapa"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .map: return "map"
        }
    }
}

struct CamerasView: View {
    @StateObject private var viewModel = CamerasViewModel()
    @StateObject private var favoritesUseCase = FavoriteCamerasUseCase.shared

    @State private var viewMode: CamerasViewMode = .list
    @State private var showOnlyFavorites = false
    @State private var showOnlyOnline = false
    @State private var selectedCamera: Camera?
    @State private var showCameraDetail = false

    // MARK: - Filtered Cameras

    private var filteredCameras: [Camera] {
        var result = viewModel.cameras

        // Filtra por favoritos
        if showOnlyFavorites {
            result = favoritesUseCase.filterFavorites(cameras: result)
        }

        // Filtra por online
        if showOnlyOnline {
            result = result.filter { $0.isOnline }
        }

        // Ordena com favoritos primeiro
        return favoritesUseCase.sortWithFavoritesFirst(cameras: result)
    }

    private var onlineCamerasFiltered: [Camera] {
        filteredCameras.filter { $0.isOnline }
    }

    private var offlineCamerasFiltered: [Camera] {
        filteredCameras.filter { !$0.isOnline }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtros e modo de visualização
                filterBar

                // Conteúdo principal
                if viewMode == .list {
                    listView
                } else {
                    mapView
                }
            }
            .navigationTitle("Câmeras")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    viewModePicker
                }
            }
            .refreshable {
                await viewModel.loadCameras()
            }
            .sheet(isPresented: $showCameraDetail) {
                if let camera = selectedCamera {
                    CameraDetailSheet(camera: camera)
                }
            }
        }
        .task {
            await viewModel.loadCameras()
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Filtro de favoritos
                FilterChip(
                    title: "Favoritos",
                    icon: "heart.fill",
                    isActive: showOnlyFavorites,
                    activeColor: .red
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        showOnlyFavorites.toggle()
                    }
                }

                // Filtro de online
                FilterChip(
                    title: "Online",
                    icon: "circle.fill",
                    isActive: showOnlyOnline,
                    activeColor: .green
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        showOnlyOnline.toggle()
                    }
                }

                Spacer()

                // Contador
                Text("\(filteredCameras.count) câmeras")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        Menu {
            ForEach(CamerasViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewMode = mode
                    }
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                }
            }
        } label: {
            Image(systemName: viewMode.icon)
                .font(.system(size: 16, weight: .medium))
        }
    }

    // MARK: - List View

    private var listView: some View {
        Group {
            if viewModel.isLoading && viewModel.cameras.isEmpty {
                LoadingView()
            } else if filteredCameras.isEmpty {
                emptyState
            } else {
                List {
                    // Favoritos (se não estiver filtrando só favoritos)
                    if !showOnlyFavorites {
                        let favorites = filteredCameras.filter { favoritesUseCase.isFavorite($0.id) }
                        if !favorites.isEmpty {
                            Section {
                                ForEach(favorites) { camera in
                                    CameraRow(
                                        camera: camera,
                                        isFavorite: true,
                                        onFavoriteToggle: { toggleFavorite(camera) },
                                        onTap: { selectCamera(camera) }
                                    )
                                }
                            } header: {
                                Label("Favoritos", systemImage: "heart.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    // Online
                    if !onlineCamerasFiltered.isEmpty {
                        Section("Online") {
                            ForEach(onlineCamerasFiltered) { camera in
                                if !favoritesUseCase.isFavorite(camera.id) || showOnlyFavorites {
                                    CameraRow(
                                        camera: camera,
                                        isFavorite: favoritesUseCase.isFavorite(camera.id),
                                        onFavoriteToggle: { toggleFavorite(camera) },
                                        onTap: { selectCamera(camera) }
                                    )
                                }
                            }
                        }
                    }

                    // Offline
                    if !offlineCamerasFiltered.isEmpty && !showOnlyOnline {
                        Section("Offline") {
                            ForEach(offlineCamerasFiltered) { camera in
                                if !favoritesUseCase.isFavorite(camera.id) || showOnlyFavorites {
                                    CameraRow(
                                        camera: camera,
                                        isFavorite: favoritesUseCase.isFavorite(camera.id),
                                        onFavoriteToggle: { toggleFavorite(camera) },
                                        onTap: { selectCamera(camera) }
                                    )
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Map View

    private var mapView: some View {
        CamerasMapView(
            cameras: filteredCameras,
            onCameraSelected: { camera in
                selectCamera(camera)
            }
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: showOnlyFavorites ? "heart.slash" : "video.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(showOnlyFavorites ? "Nenhum favorito" : "Nenhuma câmera")
                .font(.headline)

            Text(showOnlyFavorites
                 ? "Você ainda não favoritou nenhuma câmera."
                 : "Não há câmeras disponíveis no momento.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if showOnlyFavorites {
                Button("Ver todas") {
                    showOnlyFavorites = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func toggleFavorite(_ camera: Camera) {
        _ = favoritesUseCase.toggleFavorite(camera.id)
    }

    private func selectCamera(_ camera: Camera) {
        selectedCamera = camera
        showCameraDetail = true
    }
}

// MARK: - Camera Row

struct CameraRow: View {
    let camera: Camera
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void

    @State private var favoriteState: Bool

    init(camera: Camera, isFavorite: Bool, onFavoriteToggle: @escaping () -> Void, onTap: @escaping () -> Void) {
        self.camera = camera
        self.isFavorite = isFavorite
        self.onFavoriteToggle = onFavoriteToggle
        self.onTap = onTap
        self._favoriteState = State(initialValue: isFavorite)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.2, blue: 0.3),
                                    Color(red: 0.1, green: 0.15, blue: 0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 60)

                    if let thumbnailURL = camera.thumbnailURL {
                        AsyncImage(url: thumbnailURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            default:
                                Image(systemName: "video.fill")
                                    .foregroundStyle(camera.isOnline ? .green : .gray)
                            }
                        }
                    } else {
                        Image(systemName: "video.fill")
                            .foregroundStyle(camera.isOnline ? .green : .gray)
                    }

                    // Status badge
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(camera.isOnline ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                        }
                        Spacer()
                    }
                    .padding(4)
                }
                .frame(width: 80, height: 60)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(camera.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if let neighborhood = camera.location.neighborhood {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 10))
                            Text(neighborhood)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        Text(camera.isOnline ? "Online" : "Offline")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(camera.isOnline ? .green : .red)
                    }
                }

                Spacer()

                // Botão de favorito
                FavoriteButton(isFavorite: $favoriteState, size: 20) { _ in
                    onFavoriteToggle()
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .onChange(of: isFavorite) { newValue in
            favoriteState = newValue
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool
    var activeColor: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))

                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isActive ? activeColor.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .foregroundStyle(isActive ? activeColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Camera Detail Sheet

struct CameraDetailSheet: View {
    let camera: Camera
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Preview da câmera
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                            .aspectRatio(16/9, contentMode: .fit)

                        if let thumbnailURL = camera.thumbnailURL {
                            AsyncImage(url: thumbnailURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    cameraPlaceholder
                                default:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        } else {
                            cameraPlaceholder
                        }

                        // Overlay de status
                        VStack {
                            HStack {
                                StatusBadge(isOnline: camera.isOnline)
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(12)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Informações
                    VStack(alignment: .leading, spacing: 16) {
                        // Nome
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Câmera")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(camera.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Divider()

                        // Localização
                        if let neighborhood = camera.location.neighborhood {
                            InfoRow(icon: "mappin.circle.fill", title: "Bairro", value: neighborhood)
                        }

                        // Status
                        InfoRow(
                            icon: camera.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill",
                            title: "Status",
                            value: camera.isOnline ? "Online" : "Offline",
                            valueColor: camera.isOnline ? .green : .red
                        )

                        // Última atualização
                        InfoRow(
                            icon: "clock.fill",
                            title: "Última atualização",
                            value: formatDate(camera.lastUpdate)
                        )

                        Divider()

                        // Botão de stream (se online)
                        if camera.isOnline, camera.streamURL != nil {
                            Button {
                                // TODO: Abrir player de stream
                            } label: {
                                Label("Assistir ao Vivo", systemImage: "play.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.7, blue: 0.5),
                                                Color(red: 0.0, green: 0.5, blue: 0.4)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var cameraPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "video.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))

            if !camera.isOnline {
                Text("Câmera Offline")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - Preview

#Preview {
    CamerasView()
}
