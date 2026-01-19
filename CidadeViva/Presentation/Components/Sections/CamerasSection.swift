import SwiftUI

struct CamerasSection: View {
    let cameras: [Camera]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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

            // Grid de câmeras
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cameras) { camera in
                    CameraCard(camera: camera)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(AppConfiguration.backgroundPrimary)
    }
}

struct CameraCard: View {
    let camera: Camera

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8B5CF6").opacity(0.3), AppConfiguration.primaryBlue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "video.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.5))

                // Status badge
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(camera.isOnline ? AppConfiguration.success : AppConfiguration.error)
                                .frame(width: 6, height: 6)
                            Text(camera.isOnline ? "AO VIVO" : "OFFLINE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(camera.isOnline ? AppConfiguration.success.opacity(0.9) : AppConfiguration.error.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(8)
                    }
                    Spacer()
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                    .lineLimit(2)

                if let address = camera.location.address {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 9))
                        Text(address)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(AppConfiguration.textTertiary)
                    .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    ScrollView {
        CamerasSection(cameras: MockData.cameras)
    }
}
