//
//  MapView.swift
//  CidadeViva
//
//  Tela de mapa com câmeras e alertas
//

import SwiftUI
import MapKit

struct MapView: View {

    @ObservedObject var viewModel: MapViewModel
    @State private var showLegend = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mapContent

            // Controles flutuantes
            VStack(spacing: 12) {
                // Botão de legenda
                legendButton

                // Botão de localização
                locationButton

                Spacer()

                // Controles de visibilidade
                visibilityControls
            }
            .padding()
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLegend) {
            legendSheet
        }
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadMapData()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: mapAnnotations
        ) { item in
            MapAnnotation(coordinate: item.coordinate) {
                annotationView(for: item)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Map Annotations

    private var mapAnnotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []

        // Adiciona câmeras
        if viewModel.showCameras {
            items += viewModel.visibleCameras.map { camera in
                MapAnnotationItem(
                    id: camera.id,
                    type: .camera(camera),
                    coordinate: camera.coordinate
                )
            }
        }

        // Adiciona alertas
        if viewModel.showAlerts {
            items += viewModel.visibleAlerts.compactMap { alert in
                guard let coordinate = alert.coordinate else { return nil }
                return MapAnnotationItem(
                    id: alert.id,
                    type: .alert(alert),
                    coordinate: coordinate
                )
            }
        }

        return items
    }

    private func annotationView(for item: MapAnnotationItem) -> some View {
        Group {
            switch item.type {
            case .camera(let camera):
                cameraAnnotation(camera)
            case .alert(let alert):
                alertAnnotation(alert)
            }
        }
    }

    private func cameraAnnotation(_ camera: Camera) -> some View {
        Button(action: {
            viewModel.centerOnCamera(camera)
        }) {
            ZStack {
                Circle()
                    .fill(Color(camera.status.colorName))
                    .frame(width: 40, height: 40)

                Image(systemName: "video.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            .shadow(radius: 4)
        }
        .overlay(alignment: .top) {
            if viewModel.selectedCamera?.id == camera.id {
                cameraCallout(camera)
            }
        }
    }

    private func alertAnnotation(_ alert: Alert) -> some View {
        Button(action: {
            viewModel.centerOnAlert(alert)
        }) {
            ZStack {
                Circle()
                    .fill(Color(alert.severity.colorName))
                    .frame(width: 40, height: 40)

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            .shadow(radius: 4)
        }
        .overlay(alignment: .top) {
            if viewModel.selectedAlert?.id == alert.id {
                alertCallout(alert)
            }
        }
    }

    // MARK: - Callouts

    private func cameraCallout(_ camera: Camera) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(camera.name)
                .font(.headline)

            HStack {
                Label(camera.region, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label(camera.statusText, systemImage: camera.status.iconName)
                    .font(.caption)
                    .foregroundColor(Color(camera.status.colorName))
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
        .frame(width: 250)
        .offset(y: -60)
    }

    private func alertCallout(_ alert: Alert) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(alert.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(alert.severity.description)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(alert.severity.colorName))
                    .cornerRadius(4)
            }

            Text(alert.title)
                .font(.headline)
                .lineLimit(2)

            Text(alert.location)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
        .frame(width: 250)
        .offset(y: -60)
    }

    // MARK: - Controls

    private var legendButton: some View {
        Button(action: { showLegend = true }) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color("PrimaryColor"))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }

    private var locationButton: some View {
        Button(action: {
            viewModel.centerOnUserLocation()
        }) {
            Image(systemName: "location.fill")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color("PrimaryColor"))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }

    private var visibilityControls: some View {
        VStack(spacing: 8) {
            toggleButton(
                icon: "video.fill",
                isOn: viewModel.showCameras,
                color: Color("SecondaryColor")
            ) {
                viewModel.toggleCamerasVisibility()
            }

            toggleButton(
                icon: "exclamationmark.triangle.fill",
                isOn: viewModel.showAlerts,
                color: Color("AlertColor")
            ) {
                viewModel.toggleAlertsVisibility()
            }
        }
    }

    private func toggleButton(icon: String, isOn: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isOn ? .white : .gray)
                .frame(width: 44, height: 44)
                .background(isOn ? color : Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }

    // MARK: - Legend Sheet

    private var legendSheet: some View {
        NavigationStack {
            List {
                Section("Câmeras") {
                    legendItem(icon: "video.fill", color: Color("SecondaryColor"), title: "Online")
                    legendItem(icon: "video.fill", color: Color("AlertColor"), title: "Offline")
                    legendItem(icon: "video.fill", color: Color("WarningColor"), title: "Manutenção")
                }

                Section("Alertas") {
                    legendItem(icon: "exclamationmark.triangle.fill", color: Color("SecondaryColor"), title: "Baixa Severidade")
                    legendItem(icon: "exclamationmark.triangle.fill", color: Color("WarningColor"), title: "Média Severidade")
                    legendItem(icon: "exclamationmark.triangle.fill", color: Color("AlertColor"), title: "Alta Severidade")
                }
            }
            .navigationTitle("Legenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        showLegend = false
                    }
                }
            }
        }
    }

    private func legendItem(icon: String, color: Color, title: String) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }

            Text(title)
                .font(.body)

            Spacer()
        }
    }
}

// MARK: - Map Annotation Item

private struct MapAnnotationItem: Identifiable {
    let id: String
    let type: AnnotationType
    let coordinate: CLLocationCoordinate2D

    enum AnnotationType {
        case camera(Camera)
        case alert(Alert)
    }
}

#Preview {
    NavigationStack {
        MapView(viewModel: MapViewModel())
    }
}
