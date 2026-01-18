//
//  Camera.swift
//  CidadeViva
//
//  Modelo de domínio para câmeras de monitoramento
//

import Foundation
import Combine
import CoreLocation

/// Representa uma câmera de monitoramento urbano
struct Camera: Identifiable, Hashable {

    // MARK: - Properties

    let id: String
    let name: String
    let region: String
    let status: CameraStatus
    let coordinate: CLLocationCoordinate2D
    let streamURL: String?
    let thumbnailURL: String?
    let lastUpdate: Date

    // MARK: - Computed Properties

    /// Status formatado para exibição
    var statusText: String {
        status.description
    }

    /// Indica se a câmera está ativa
    var isActive: Bool {
        status == .online
    }

    /// Última atualização formatada
    var lastUpdateFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Camera, rhs: Camera) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Camera Status

/// Status operacional da câmera
enum CameraStatus: String, Codable {
    case online = "online"
    case offline = "offline"
    case maintenance = "maintenance"

    /// Descrição legível
    var description: String {
        switch self {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .maintenance:
            return "Manutenção"
        }
    }

    /// Cor associada ao status
    var colorName: String {
        switch self {
        case .online:
            return "SecondaryColor" // Verde
        case .offline:
            return "AlertColor" // Vermelho
        case .maintenance:
            return "WarningColor" // Laranja
        }
    }

    /// Ícone SF Symbol
    var iconName: String {
        switch self {
        case .online:
            return "checkmark.circle.fill"
        case .offline:
            return "xmark.circle.fill"
        case .maintenance:
            return "wrench.and.screwdriver.fill"
        }
    }
}
