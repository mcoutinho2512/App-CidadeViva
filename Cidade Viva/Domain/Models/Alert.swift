//
//  Alert.swift
//  CidadeViva
//
//  Modelo de domínio para alertas urbanos
//

import Foundation
import CoreLocation

/// Representa um alerta urbano
struct Alert: Identifiable, Hashable {

    // MARK: - Properties

    let id: String
    let type: AlertType
    let severity: AlertSeverity
    let title: String
    let description: String
    let location: String
    let coordinate: CLLocationCoordinate2D?
    let createdAt: Date
    let expiresAt: Date?
    let isActive: Bool

    // MARK: - Computed Properties

    /// Horário de criação formatado
    var createdAtFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    /// Data de expiração formatada
    var expiresAtFormatted: String? {
        guard let expiresAt = expiresAt else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: expiresAt)
    }

    /// Indica se o alerta está expirado
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Alert, rhs: Alert) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Alert Type

/// Tipos de alertas urbanos
enum AlertType: String, Codable {
    case traffic = "traffic"
    case weather = "weather"
    case security = "security"
    case infrastructure = "infrastructure"
    case event = "event"
    case emergency = "emergency"

    /// Descrição legível
    var description: String {
        switch self {
        case .traffic:
            return "Trânsito"
        case .weather:
            return "Clima"
        case .security:
            return "Segurança"
        case .infrastructure:
            return "Infraestrutura"
        case .event:
            return "Evento"
        case .emergency:
            return "Emergência"
        }
    }

    /// Ícone SF Symbol
    var iconName: String {
        switch self {
        case .traffic:
            return "car.fill"
        case .weather:
            return "cloud.bolt.fill"
        case .security:
            return "shield.fill"
        case .infrastructure:
            return "building.2.fill"
        case .event:
            return "calendar.badge.exclamationmark"
        case .emergency:
            return "bell.badge.fill"
        }
    }
}

// MARK: - Alert Severity

/// Níveis de severidade dos alertas
enum AlertSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"

    /// Descrição legível
    var description: String {
        switch self {
        case .low:
            return "Baixa"
        case .medium:
            return "Média"
        case .high:
            return "Alta"
        case .critical:
            return "Crítica"
        }
    }

    /// Cor associada à severidade
    var colorName: String {
        switch self {
        case .low:
            return "SecondaryColor" // Verde
        case .medium:
            return "WarningColor" // Laranja
        case .high:
            return "AlertColor" // Vermelho
        case .critical:
            return "AlertColor" // Vermelho
        }
    }

    /// Prioridade numérica (maior = mais grave)
    var priority: Int {
        switch self {
        case .low:
            return 1
        case .medium:
            return 2
        case .high:
            return 3
        case .critical:
            return 4
        }
    }
}
