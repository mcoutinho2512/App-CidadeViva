import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.pointsOfInterest) { poi in
                    MapAnnotation(coordinate: poi.location.coordinate) {
                        POIAnnotationView(poi: poi) {
                            viewModel.selectedPOI = poi
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button {
                            viewModel.centerOnUserLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Todos") {
                            viewModel.filterByCategory(nil)
                        }
                        ForEach(PointOfInterest.Category.allCases, id: \.self) { category in
                            Button {
                                viewModel.filterByCategory(category)
                            } label: {
                                Label(category.rawValue, systemImage: category.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $viewModel.selectedPOI) { poi in
                POIDetailSheet(poi: poi)
                    .presentationDetents([.medium])
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct POIAnnotationView: View {
    let poi: PointOfInterest
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: poi.category.iconName)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(AppConfiguration.primaryBlue)
                    .clipShape(Circle())

                Text(poi.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
}

struct POIDetailSheet: View {
    let poi: PointOfInterest

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: poi.category.iconName)
                    .font(.title)
                    .foregroundStyle(AppConfiguration.primaryBlue)

                VStack(alignment: .leading) {
                    Text(poi.name)
                        .font(.headline)
                    Text(poi.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let rating = poi.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                    }
                    .font(.subheadline)
                }
            }

            Text(poi.description)
                .font(.body)

            Divider()

            if let address = poi.location.address {
                Label(address, systemImage: "mappin")
                    .font(.subheadline)
            }

            if let phone = poi.phone {
                Label(phone, systemImage: "phone")
                    .font(.subheadline)
            }

            if let hours = poi.openingHours {
                Label(hours, systemImage: "clock")
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    MapView()
}
