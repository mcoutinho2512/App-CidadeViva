//
//  CamerasView.swift
//  CidadeViva
//
//  Tela de câmeras REDESENHADA - Premium & Futurista
//

import SwiftUI

struct CamerasView: View {

    @ObservedObject var viewModel: CamerasViewModel
    @State private var showFilterSheet = false
    @State private var searchFieldFocused = false

    var body: some View {
        ZStack {
            // Fundo premium
            Color.backgroundDark
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingViewPremium(message: "Carregando câmeras...")

            case .success:
                camerasContent

            case .error(let error):
                ErrorViewPremium(error: error) {
                    Task {
                        await viewModel.loadCameras()
                    }
                }
            }
        }
        .navigationTitle("Câmeras")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilterSheet = true }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(
                                LinearGradient.primary
                            )
                    }
                }
                .bouncePress()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheetPremium
        }
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadCameras()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Cameras Content

    private var camerasContent: some View {
        VStack(spacing: 0) {
            // Stats premium
            statsBarPremium
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.vertical, Spacing.lg)
            
            // Search bar premium
            searchBarPremium
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.bottom, Spacing.lg)

            // Lista de câmeras
            if viewModel.filteredCameras.isEmpty {
                emptyStatePremium
            } else {
                camerasListPremium
            }
        }
    }

    // MARK: - Stats Bar Premium

    private var statsBarPremium: some View {
        HStack(spacing: Spacing.md) {
            // Online
            StatPillView(
                icon: "checkmark.circle.fill",
                value: viewModel.onlineCamerasCount,
                label: "Online",
                color: .successNeon
            )
            
            // Offline
            StatPillView(
                icon: "xmark.circle.fill",
                value: viewModel.offlineCamerasCount,
                label: "Offline",
                color: .errorVibrant
            )
            
            Spacer()
            
            // Total contador
            VStack(alignment: .trailing, spacing: 2) {
                AnimatedCounter(value: viewModel.filteredCameras.count)
                    .font(.title3Custom)
                    .foregroundStyle(Color.textPrimary)
                
                Text("de \(viewModel.cameras.count)")
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    // MARK: - Search Bar Premium

    private var searchBarPremium: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(searchFieldFocused ? LinearGradient.primary : LinearGradient(colors: [Color.textSecondary], startPoint: .leading, endPoint: .trailing))
                .animation(.smooth, value: searchFieldFocused)

            TextField("Buscar por nome ou região", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .foregroundStyle(Color.textPrimary)
            .font(.bodyCustom)

            if !viewModel.searchText.isEmpty {
                Button(action: { 
                    viewModel.updateSearchText("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(Spacing.lg)
        .glassCard(padding: 0)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardRadius)
                .stroke(
                    searchFieldFocused ? LinearGradient.primary : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 2
                )
        )
        .animation(.smooth, value: searchFieldFocused)
    }

    // MARK: - Cameras List Premium

    private var camerasListPremium: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.cardSpacing) {
                ForEach(Array(viewModel.filteredCameras.enumerated()), id: \.element.id) { index, camera in
                    CameraStatusCard(camera: camera)
                        .staggeredAppearance(index: index)
                }
            }
            .padding(Spacing.screenPadding)
            .tabBarSafeAreaPadding()
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
                
                Image(systemName: "video.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: Spacing.md) {
                Text("Nenhuma câmera encontrada")
                    .font(.title2Custom)
                    .foregroundStyle(Color.textPrimary)

                if viewModel.selectedRegion != .all || viewModel.selectedStatus != nil || !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearFilters()
                    }) {
                        Text("Limpar Filtros")
                            .font(.bodyCustom)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.md)
                            .background(
                                Capsule()
                                    .fill(LinearGradient.primary)
                            )
                    }
                    .bouncePress()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.screenPadding)
    }

    // MARK: - Filter Sheet Premium

    private var filterSheetPremium: some View {
        NavigationStack {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Região
                        filterSection(title: "Região", icon: "map.fill") {
                            FilterPillGroup(
                                options: CityRegion.allCases.map { $0.displayName },
                                selectedIndex: Binding(
                                    get: { CityRegion.allCases.firstIndex(of: viewModel.selectedRegion) ?? 0 },
                                    set: { viewModel.selectRegion(CityRegion.allCases[$0]) }
                                )
                            )
                        }
                        
                        // Status
                        filterSection(title: "Status", icon: "circle.fill") {
                            FilterPillGroup(
                                options: ["Todos", "Online", "Offline", "Manutenção"],
                                selectedIndex: Binding(
                                    get: {
                                        if viewModel.selectedStatus == nil { return 0 }
                                        if viewModel.selectedStatus == .online { return 1 }
                                        if viewModel.selectedStatus == .offline { return 2 }
                                        return 3
                                    },
                                    set: {
                                        switch $0 {
                                        case 0: viewModel.selectStatus(nil)
                                        case 1: viewModel.selectStatus(.online)
                                        case 2: viewModel.selectStatus(.offline)
                                        default: viewModel.selectStatus(.maintenance)
                                        }
                                    }
                                )
                            )
                        }
                        
                        // Botão limpar
                        Button(action: {
                            viewModel.clearFilters()
                            showFilterSheet = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Limpar Todos os Filtros")
                            }
                            .font(.title3Custom)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: Spacing.cardRadius)
                                    .fill(LinearGradient.fire)
                            )
                        }
                        .bouncePress()
                    }
                    .padding(Spacing.screenPadding)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        showFilterSheet = false
                    }
                    .foregroundStyle(LinearGradient.primary)
                }
            }
        }
    }
    
    private func filterSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Label(title, systemImage: icon)
                .font(.title3Custom)
                .foregroundStyle(Color.textPrimary)
            
            content()
        }
        .padding(Spacing.xl)
        .glassCard(padding: 0)
    }
}

// MARK: - Stat Pill View

struct StatPillView: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .glow(color: color, radius: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                AnimatedCounter(value: value)
                    .font(.title3Custom)
                    .foregroundStyle(Color.textPrimary)
                
                Text(label)
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Filter Pill Group

struct FilterPillGroup: View {
    let options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    FilterPill(
                        title: option,
                        isSelected: index == selectedIndex,
                        action: {
                            withAnimation(.bouncy) {
                                selectedIndex = index
                            }
                        }
                    )
                }
            }
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyCustom)
                .foregroundStyle(isSelected ? .white : .textSecondary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .fill(isSelected ? LinearGradient.primary : LinearGradient(colors: [.backgroundCard], startPoint: .leading, endPoint: .trailing))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? .clear : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .bouncePress()
    }
}

#Preview {
    NavigationStack {
        CamerasView(viewModel: CamerasViewModel())
            .preferredColorScheme(.dark)
    }
}
