//
//  POIsView.swift
//  CidadeViva
//
//  Tela de pontos de interesse
//

import SwiftUI
import MapKit

struct POIsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = POIsViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedPOI: PointOfInterest?
    @State private var showFilters = false
    @State private var showMapView = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Pontos de Interesse")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showMapView.toggle()
                    } label: {
                        Image(systemName: showMapView ? "list.bullet" : "map")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedPOI) { poi in
                POIDetailView(poi: poi, userLocation: locationManager.lastLocation?.coordinate)
            }
            .sheet(isPresented: $showFilters) {
                POIFiltersView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: locationManager.lastLocation) { newLocation in
                if let coordinate = newLocation?.coordinate {
                    viewModel.updateUserLocation(coordinate)
                }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if showMapView {
            mapContent
        } else {
            listContent
        }
    }

    @ViewBuilder
    private var listContent: some View {
        switch viewModel.state {
        case .idle:
            Color.clear

        case .loading:
            ProgressView("Carregando pontos de interesse...")

        case .success:
            if viewModel.filteredPOIs.isEmpty {
                emptyState
            } else {
                poisList
            }

        case .failure(let error):
            ErrorView(
                message: error.localizedDescription,
                retryAction: {
                    Task {
                        await viewModel.loadData()
                    }
                }
            )
        }
    }

    private var poisList: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Rated POIs
                if !viewModel.topRatedPOIs.isEmpty && viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mais Bem Avaliados")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.topRatedPOIs) { poi in
                                    TopRatedPOICard(poi: poi)
                                        .onTapGesture {
                                            selectedPOI = poi
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Buscar pontos de interesse...")
                    .padding(.horizontal)

                // Type Filter
                if viewModel.searchText.isEmpty {
                    POITypeFilterView(
                        selectedType: $viewModel.selectedType,
                        onTypeSelected: { type in
                            viewModel.selectType(type)
                        }
                    )
                }

                // POIs List
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredPOIs) { poi in
                        POICard(
                            poi: poi,
                            distance: viewModel.distanceFromUserFormatted(to: poi)
                        )
                        .onTapGesture {
                            selectedPOI = poi
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var mapContent: some View {
        POIsMapView(
            pois: viewModel.filteredPOIs,
            userLocation: locationManager.lastLocation?.coordinate,
            selectedPOI: $selectedPOI,
            region: .constant(MKCoordinateRegion(
                center: locationManager.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Nenhum ponto encontrado")
                .font(.headline)

            Text("Tente ajustar os filtros de busca")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if viewModel.selectedType != nil || !viewModel.searchText.isEmpty {
                Button("Limpar Filtros") {
                    viewModel.clearFilters()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// MARK: - Top Rated POI Card

struct TopRatedPOICard: View {
    let poi: PointOfInterest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image or Icon
            ZStack {
                if let imageURL = poi.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                } else {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .overlay(
                            Text(poi.type.emoji)
                                .font(.system(size: 40))
                        )
                }
            }
            .frame(width: 200, height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(poi.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let rating = poi.rating {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - POI Card

struct POICard: View {
    let poi: PointOfInterest
    let distance: String?

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Text(poi.type.emoji)
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(poi.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(poi.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(poi.address, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)

                HStack {
                    if let rating = poi.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }

                    if let distance = distance {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(distance)
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - POI Type Filter View

struct POITypeFilterView: View {
    @Binding var selectedType: POIType?
    let onTypeSelected: (POIType?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                POITypeChip(
                    title: "Todos",
                    emoji: "📍",
                    isSelected: selectedType == nil,
                    action: {
                        onTypeSelected(nil)
                    }
                )

                ForEach(POIType.allCases, id: \.self) { type in
                    POITypeChip(
                        title: type.description,
                        emoji: type.emoji,
                        isSelected: selectedType == type,
                        action: {
                            onTypeSelected(type)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct POITypeChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.body)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - POI Filters View

struct POIFiltersView: View {
    @ObservedObject var viewModel: POIsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Filtros") {
                    Toggle("Apenas Próximos", isOn: Binding(
                        get: { viewModel.showNearbyOnly },
                        set: { _ in viewModel.toggleNearby() }
                    ))

                    if viewModel.showNearbyOnly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Raio: \(String(format: "%.1f", viewModel.nearbyRadius / 1000)) km")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Slider(value: Binding(
                                get: { viewModel.nearbyRadius },
                                set: { viewModel.updateNearbyRadius($0) }
                            ), in: 1000...20000, step: 1000)
                        }
                    }
                }

                Section {
                    Button("Limpar Todos os Filtros") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filtros")
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
}

// MARK: - POIs Map View

struct POIsMapView: View {
    let pois: [PointOfInterest]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedPOI: PointOfInterest?
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pois) { poi in
            MapAnnotation(coordinate: poi.coordinate) {
                Button {
                    selectedPOI = poi
                } label: {
                    VStack {
                        Text(poi.type.emoji)
                            .font(.title)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)

                        Text(poi.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - POI Detail View

struct POIDetailView: View {
    let poi: PointOfInterest
    let userLocation: CLLocationCoordinate2D?
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion

    init(poi: PointOfInterest, userLocation: CLLocationCoordinate2D?) {
        self.poi = poi
        self.userLocation = userLocation
        _region = State(initialValue: MKCoordinateRegion(
            center: poi.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Map Preview
                    Map(coordinateRegion: $region, annotationItems: [poi]) { poi in
                        MapAnnotation(coordinate: poi.coordinate) {
                            Text(poi.type.emoji)
                                .font(.title)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Type
                        HStack {
                            Text(poi.type.emoji)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(poi.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(poi.type.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Rating
                        if let rating = poi.rating {
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Description
                        if let description = poi.description {
                            Text(description)
                                .font(.body)
                        }

                        Divider()

                        // Address
                        POIInfoRow(icon: "mappin.circle.fill", title: "Endereço", value: poi.address)

                        // Opening Hours
                        if let hours = poi.openingHours {
                            POIInfoRow(icon: "clock.fill", title: "Horário", value: hours)
                        }

                        // Contact
                        if let phone = poi.phone {
                            Button {
                                if let url = poi.phoneURL {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                POIInfoRow(icon: "phone.fill", title: "Telefone", value: phone)
                            }
                        }

                        if let email = poi.email {
                            Button {
                                if let url = poi.emailURL {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                POIInfoRow(icon: "envelope.fill", title: "Email", value: email)
                            }
                        }

                        if let website = poi.website {
                            Button {
                                if let url = poi.websiteURL {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                POIInfoRow(icon: "link", title: "Website", value: website)
                            }
                        }

                        // Directions Button
                        Button {
                            openInMaps()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Abrir no Mapas", systemImage: "map.fill")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
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

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: poi.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = poi.name
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct POIInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

// MARK: - Preview

struct POIsView_Previews: PreviewProvider {
    static var previews: some View {
        POIsView()
    }
}
