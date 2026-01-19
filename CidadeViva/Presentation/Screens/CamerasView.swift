import SwiftUI

struct CamerasView: View {
    @StateObject private var viewModel = CamerasViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.onlineCameras.isEmpty {
                    Section("Online") {
                        ForEach(viewModel.onlineCameras) { camera in
                            CameraRow(camera: camera)
                        }
                    }
                }

                if !viewModel.offlineCameras.isEmpty {
                    Section("Offline") {
                        ForEach(viewModel.offlineCameras) { camera in
                            CameraRow(camera: camera)
                        }
                    }
                }
            }
            .navigationTitle("Câmeras")
            .refreshable {
                await viewModel.loadCameras()
            }
            .overlay {
                if viewModel.isLoading && viewModel.cameras.isEmpty {
                    LoadingView()
                } else if viewModel.cameras.isEmpty && viewModel.error == nil {
                    EmptyStateView(
                        title: "Nenhuma câmera",
                        systemImage: "video.slash",
                        description: "Não há câmeras disponíveis no momento."
                    )
                }
            }
        }
        .task {
            await viewModel.loadCameras()
        }
    }
}

struct CameraRow: View {
    let camera: Camera

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 80, height: 60)

                Image(systemName: "video.fill")
                    .foregroundStyle(camera.isOnline ? .green : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.subheadline)
                    .bold()

                if let address = camera.location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Circle()
                        .fill(camera.isOnline ? .green : .red)
                        .frame(width: 8, height: 8)

                    Text(camera.isOnline ? "Online" : "Offline")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CamerasView()
}
