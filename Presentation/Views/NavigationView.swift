//
//  NavigationView.swift
//  CidadeViva
//
//  Tela de navegação e rotas
//

import SwiftUI
import MapKit

struct NavigationView: View {

    // MARK: - Properties

    @StateObject private var viewModel = NavigationViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showPOISelector = false
    @State private var showModeSelector = false

    // MARK: - Body

    var body: some View {
        SwiftUI.NavigationView {
            ZStack {
                // Map
                mapView

                // Overlay Controls
                VStack {
                    Spacer()

                    // Route Info Card
                    if let route = viewModel.currentRoute {
                        routeInfoCard(route: route)
                            .padding()
                            .transition(.move(edge: .bottom))
                    } else {
                        routeSetupCard
                            .padding()
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Navegação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentRoute != nil {
                        Button {
                            viewModel.clearRoute()
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showPOISelector) {
                POISelectorView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showRouteInstructions) {
                if let route = viewModel.currentRoute {
                    RouteInstructionsView(route: route)
                }
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let coordinate = newLocation?.coordinate, viewModel.origin == nil {
                    viewModel.setOrigin(coordinate)
                }
            }
        }
    }

    // MARK: - Map View

    private var mapView: some View {
        Map(coordinateRegion: $viewModel.mapRegion, showsUserLocation: true, annotationItems: annotations) { item in
            MapAnnotation(coordinate: item.coordinate) {
                annotationView(for: item)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []

        if let origin = viewModel.origin {
            items.append(MapAnnotationItem(id: "origin", type: .origin, coordinate: origin))
        }

        if let destination = viewModel.destination {
            items.append(MapAnnotationItem(id: "destination", type: .destination, coordinate: destination))
        }

        return items
    }

    @ViewBuilder
    private func annotationView(for item: MapAnnotationItem) -> some View {
        VStack {
            Image(systemName: item.type == .origin ? "location.circle.fill" : "mappin.circle.fill")
                .font(.title)
                .foregroundColor(item.type == .origin ? .blue : .red)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 3)

            Text(item.type == .origin ? "Origem" : "Destino")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
        }
    }

    // MARK: - Route Setup Card

    private var routeSetupCard: some View {
        VStack(spacing: 16) {
            Text("Planejar Rota")
                .font(.headline)

            VStack(spacing: 12) {
                // Origin
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)

                    if viewModel.origin != nil {
                        VStack(alignment: .leading) {
                            Text("Origem")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Localização Atual")
                                .font(.subheadline)
                        }
                    } else {
                        Text("Definir origem...")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        if let location = locationManager.lastLocation?.coordinate {
                            viewModel.setOrigin(location)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)

                // Swap Button
                Button {
                    viewModel.swapOriginAndDestination()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.blue)
                }

                // Destination
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)

                    if let poi = viewModel.selectedPOI {
                        VStack(alignment: .leading) {
                            Text("Destino")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(poi.name)
                                .font(.subheadline)
                        }
                    } else if viewModel.destination != nil {
                        VStack(alignment: .leading) {
                            Text("Destino")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Local selecionado")
                                .font(.subheadline)
                        }
                    } else {
                        Text("Escolher destino...")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        showPOISelector = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }

            // Mode Selector
            Picker("Modo", selection: $viewModel.selectedMode) {
                ForEach(RouteMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.icon)
                        Text(mode.description)
                    }
                    .tag(mode)
                }
            }
            .pickerStyle(.segmented)

            // Calculate Button
            Button {
                Task {
                    await viewModel.calculateRoute()
                }
            } label: {
                HStack {
                    Spacer()
                    if case .loading = viewModel.routeState {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Calcular Rota")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding()
                .background(viewModel.canCalculateRoute ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!viewModel.canCalculateRoute)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }

    // MARK: - Route Info Card

    private func routeInfoCard(route: Route) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rota Calculada")
                        .font(.headline)

                    Text(route.mode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    viewModel.toggleRouteInstructions()
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.blue)
                }
            }

            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "arrow.left.and.right")
                        .foregroundColor(.blue)
                    Text(route.distanceFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Distância")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(route.durationFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Tempo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                openInMaps(route: route)
            } label: {
                HStack {
                    Spacer()
                    Label("Abrir no Apple Maps", systemImage: "map.fill")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            HStack {
                Button {
                    viewModel.clearRoute()
                } label: {
                    HStack {
                        Spacer()
                        Text("Nova Rota")
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Button {
                    Task {
                        await viewModel.calculateRoute()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                        Text("Atualizar")
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }

    // MARK: - Helper Methods

    private func openInMaps(route: Route) {
        let originPlacemark = MKPlacemark(coordinate: route.origin.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: route.destination.coordinate)

        let originItem = MKMapItem(placemark: originPlacemark)
        originItem.name = route.origin.name

        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        destinationItem.name = route.destination.name

        var transportType: MKDirectionsTransportType {
            switch route.mode {
            case .walking:
                return .walking
            case .driving:
                return .automobile
            case .cycling:
                return .walking // Apple Maps doesn't have cycling, use walking
            }
        }

        MKMapItem.openMaps(
            with: [originItem, destinationItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: transportType
            ]
        )
    }
}

// MARK: - Map Annotation Item

struct MapAnnotationItem: Identifiable {
    let id: String
    let type: AnnotationType
    let coordinate: CLLocationCoordinate2D

    enum AnnotationType {
        case origin
        case destination
    }
}

// MARK: - POI Selector View

struct POISelectorView: View {
    @ObservedObject var viewModel: NavigationViewModel
    @StateObject private var poisViewModel = POIsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        SwiftUI.NavigationView {
            List {
                ForEach(poisViewModel.filteredPOIs) { poi in
                    Button {
                        viewModel.setDestination(poi: poi)
                        dismiss()
                    } label: {
                        HStack {
                            Text(poi.type.emoji)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(poi.name)
                                    .font(.headline)
                                Text(poi.address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Escolher Destino")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $poisViewModel.searchText, prompt: "Buscar ponto de interesse")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .task {
                await poisViewModel.loadData()
            }
        }
    }
}

// MARK: - Route Instructions View

struct RouteInstructionsView: View {
    let route: Route
    @Environment(\.dismiss) var dismiss

    var body: some View {
        SwiftUI.NavigationView {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(route.distanceFormatted)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Distância total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(route.durationFormatted)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Tempo estimado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                if let instructions = route.instructions, !instructions.isEmpty {
                    Section("Instruções") {
                        ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 32, height: 32)

                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(instruction.instruction)
                                        .font(.body)

                                    if instruction.distance > 0 {
                                        Text(formatDistance(instruction.distance))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    Section("Instruções") {
                        Text("Siga a rota no mapa")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Instruções de Rota")
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

    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

// MARK: - Preview

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView()
    }
}
