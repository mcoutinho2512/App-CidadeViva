import SwiftUI
import MapKit

struct MapaSection: View {
    let pointsOfInterest: [PointOfInterest]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -22.9035, longitude: -43.1180),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da seção
            HStack(spacing: 12) {
                Image(systemName: "map.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppConfiguration.primaryBlue, Color(hex: "06B6D4"))

                Text("Mapa da Cidade")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)

            // Mini mapa
            Map(coordinateRegion: $region, annotationItems: pointsOfInterest) { poi in
                MapAnnotation(coordinate: poi.location.coordinate) {
                    Image(systemName: poi.category.iconName)
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(AppConfiguration.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)

            // Pontos de interesse
            Text("Pontos de Interesse")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppConfiguration.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(pointsOfInterest.prefix(5)) { poi in
                        POICard(poi: poi)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 24)
        }
        .background(AppConfiguration.backgroundPrimary)
    }
}

struct POICard: View {
    let poi: PointOfInterest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Ícone
            Image(systemName: poi.category.iconName)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        colors: [AppConfiguration.primaryBlue, Color(hex: "06B6D4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(poi.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppConfiguration.textPrimary)
                .lineLimit(2)

            Text(poi.category.rawValue)
                .font(.system(size: 11))
                .foregroundStyle(AppConfiguration.textSecondary)

            if let rating = poi.rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppConfiguration.textSecondary)
                }
            }
        }
        .frame(width: 120)
        .padding(12)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    ScrollView {
        MapaSection(pointsOfInterest: MockData.pointsOfInterest)
    }
}
