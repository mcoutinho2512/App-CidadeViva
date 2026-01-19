//
//  CamerasView.swift
//  CidadeViva
//
//  Tela de câmeras de monitoramento
//

import SwiftUI

struct CamerasView: View {

    @ObservedObject var viewModel: CamerasViewModel
    @State private var showFilterSheet = false

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView(message: "Carregando câmeras...")

            case .success:
                camerasContent

            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadCameras()
                    }
                }
            }
        }
        .navigationTitle("Câmeras")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilterSheet = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
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
            // Estatísticas
            statsBar

            // Barra de busca
            searchBar

            // Lista de câmeras
            if viewModel.filteredCameras.isEmpty {
                emptyStateView
            } else {
                camerasList
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 20) {
            statItem(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.onlineCamerasCount)",
                label: "Online",
                color: Color("SecondaryColor")
            )

            Divider()
                .frame(height: 30)

            statItem(
                icon: "xmark.circle.fill",
                value: "\(viewModel.offlineCamerasCount)",
                label: "Offline",
                color: Color("AlertColor")
            )

            Spacer()

            Text("\(viewModel.filteredCameras.count) de \(viewModel.cameras.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Buscar por nome ou região", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ))
            .textFieldStyle(PlainTextFieldStyle())

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.updateSearchText("") }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Cameras List

    private var camerasList: some View {
        List {
            ForEach(viewModel.filteredCameras) { camera in
                cameraRow(camera: camera)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func cameraRow(camera: Camera) -> some View {
        HStack(spacing: 16) {
            // Indicador de status
            Circle()
                .fill(Color(camera.status.colorName))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(camera.region, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label(camera.statusText, systemImage: camera.status.iconName)
                        .font(.caption)
                        .foregroundColor(Color(camera.status.colorName))
                }
            }

            Spacer()

            if camera.isActive {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("PrimaryColor"))
            }
        }
        .padding(12)
        .cardStyle()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Nenhuma câmera encontrada")
                .font(.headline)
                .foregroundColor(.secondary)

            if viewModel.selectedRegion != .all || viewModel.selectedStatus != nil || !viewModel.searchText.isEmpty {
                Button("Limpar Filtros") {
                    viewModel.clearFilters()
                }
                .foregroundColor(Color("PrimaryColor"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Região") {
                    Picker("Região", selection: Binding(
                        get: { viewModel.selectedRegion },
                        set: { viewModel.selectRegion($0) }
                    )) {
                        ForEach(CityRegion.allCases) { region in
                            Text(region.displayName).tag(region)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section("Status") {
                    Picker("Status", selection: Binding(
                        get: { viewModel.selectedStatus },
                        set: { viewModel.selectStatus($0) }
                    )) {
                        Text("Todos").tag(nil as CameraStatus?)
                        Text("Online").tag(CameraStatus.online as CameraStatus?)
                        Text("Offline").tag(CameraStatus.offline as CameraStatus?)
                        Text("Manutenção").tag(CameraStatus.maintenance as CameraStatus?)
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section {
                    Button("Limpar Todos os Filtros") {
                        viewModel.clearFilters()
                        showFilterSheet = false
                    }
                    .foregroundColor(Color("AlertColor"))
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        showFilterSheet = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CamerasView(viewModel: CamerasViewModel())
    }
}
