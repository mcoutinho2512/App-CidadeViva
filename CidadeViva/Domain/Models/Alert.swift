import Foundation
import SwiftUI

struct Alert: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let severity: Severity
    let category: Category
    let location: Location?
    let createdAt: Date
    let expiresAt: Date?

    enum Severity: String, CaseIterable {
        case low = "Baixa"
        case medium = "Média"
        case high = "Alta"
        case critical = "Crítica"

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }

        var iconName: String {
            switch self {
            case .low: return "info.circle.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .high: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            }
        }
    }

    enum Category: String, CaseIterable {
        case traffic = "Trânsito"
        case weather = "Clima"
        case security = "Segurança"
        case health = "Saúde"
        case infrastructure = "Infraestrutura"
        case event = "Evento"
    }
}
