import SwiftUI
import MapKit

struct CamerasSection: View {
    let cameras: [Camera]

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -22.9035, longitude: -43.1180),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var selectedCamera: Camera?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da seção
            HStack(spacing: 12) {
                Image(systemName: "video.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(hex: "8B5CF6"), AppConfiguration.primaryBlue)

                Text("Câmeras ao Vivo")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()

                // Indicador online
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppConfiguration.success)
                        .frame(width: 8, height: 8)
                    Text("\(cameras.filter { $0.isOnline }.count) online")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppConfiguration.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)

            // Mapa com câmeras
            ZStack(alignment: .bottomTrailing) {
                Map(coordinateRegion: $region, annotationItems: cameras) { camera in
                    MapAnnotation(coordinate: camera.coordinate) {
                        CameraMapPin(
                            camera: camera,
                            isSelected: selectedCamera?.id == camera.id,
                            onTap: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCamera = camera
                                }
                            }
                        )
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Botões de controle do mapa
                VStack(spacing: 8) {
                    Button {
                        withAnimation {
                            region.span.latitudeDelta = max(region.span.latitudeDelta / 2, 0.01)
                            region.span.longitudeDelta = max(region.span.longitudeDelta / 2, 0.01)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Button {
                        withAnimation {
                            region.span.latitudeDelta = min(region.span.latitudeDelta * 2, 0.5)
                            region.span.longitudeDelta = min(region.span.longitudeDelta * 2, 0.5)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }
            .padding(.horizontal, 16)

            // Callout da câmera selecionada
            if let camera = selectedCamera {
                CameraInfoCard(camera: camera) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCamera = nil
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Legenda
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundStyle(AppConfiguration.textSecondary)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text("Offline")
                        .font(.system(size: 12))
                        .foregroundStyle(AppConfiguration.textSecondary)
                }

                Spacer()

                Text("\(cameras.count) câmeras")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppConfiguration.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(AppConfiguration.backgroundPrimary)
        .onAppear {
            fitAllCameras()
        }
    }

    private func fitAllCameras() {
        guard !cameras.isEmpty else { return }

        let latitudes = cameras.map { $0.location.latitude }
        let longitudes = cameras.map { $0.location.longitude }

        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else { return }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.05),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.05)
        )

        withAnimation {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}

// MARK: - Camera Map Pin

struct CameraMapPin: View {
    let camera: Camera
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(camera.isOnline ? Color.green : Color.red)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .shadow(color: (camera.isOnline ? Color.green : Color.red).opacity(0.4), radius: isSelected ? 8 : 4)

                    Image(systemName: "video.fill")
                        .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                        .foregroundStyle(.white)
                }

                // Triângulo
                PinTriangle()
                    .fill(camera.isOnline ? Color.green : Color.red)
                    .frame(width: 12, height: 8)
                    .offset(y: -2)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Pin Triangle Shape

struct PinTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Camera Info Card

struct CameraInfoCard: View {
    let camera: Camera
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Ícone
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(camera.isOnline ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: "video.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(camera.isOnline ? .green : .red)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(camera.isOnline ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(camera.isOnline ? "Online" : "Offline")
                        .font(.system(size: 12))
                        .foregroundStyle(camera.isOnline ? .green : .red)

                    if let neighborhood = camera.location.neighborhood {
                        Text("•")
                            .foregroundStyle(AppConfiguration.textTertiary)
                        Text(neighborhood)
                            .font(.system(size: 12))
                            .foregroundStyle(AppConfiguration.textSecondary)
                    }
                }
            }

            Spacer()

            // Botão fechar
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppConfiguration.textTertiary)
                    .frame(width: 28, height: 28)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
}

#Preview {
    ScrollView {
        CamerasSection(cameras: MockData.cameras)
    }
}
