import SwiftUI

struct NavigationRouteView: View {
    @StateObject private var viewModel = NavigationViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Transport Type Selector
                Picker("Tipo de Transporte", selection: $viewModel.selectedTransportType) {
                    ForEach(Route.TransportType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.iconName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Route Info
                if let route = viewModel.route {
                    VStack(spacing: 16) {
                        HStack(spacing: 32) {
                            VStack {
                                Image(systemName: "arrow.triangle.swap")
                                    .font(.title2)
                                    .foregroundStyle(AppConfiguration.primaryBlue)
                                Text(route.formattedDistance)
                                    .font(.headline)
                                Text("Distância")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            VStack {
                                Image(systemName: "clock")
                                    .font(.title2)
                                    .foregroundStyle(AppConfiguration.primaryBlue)
                                Text(route.formattedDuration)
                                    .font(.headline)
                                Text("Tempo estimado")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        Button("Limpar Rota") {
                            viewModel.clearRoute()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("Selecione origem e destino")
                            .foregroundStyle(.secondary)

                        Button {
                            viewModel.setCurrentLocationAsOrigin()
                        } label: {
                            Label("Usar localização atual", systemImage: "location.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 40)
                }

                Spacer()
            }
            .navigationTitle("Navegação")
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        }
    }
}

#Preview {
    NavigationRouteView()
}
