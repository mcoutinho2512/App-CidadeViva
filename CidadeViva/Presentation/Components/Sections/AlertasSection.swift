import SwiftUI

struct AlertasSection: View {
    let alerts: [Alert]

    private var criticalAlerts: [Alert] {
        alerts.filter { $0.severity == .critical || $0.severity == .high }
    }

    private var otherAlerts: [Alert] {
        alerts.filter { $0.severity == .medium || $0.severity == .low }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da seção
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppConfiguration.error, Color(hex: "FF6B35"))

                Text("Alertas Ativos")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()

                if !criticalAlerts.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("\(criticalAlerts.count)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppConfiguration.error)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)

            // Alertas críticos
            if !criticalAlerts.isEmpty {
                VStack(spacing: 12) {
                    ForEach(criticalAlerts) { alert in
                        AlertCard(alert: alert, style: .critical)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            // Outros alertas
            if !otherAlerts.isEmpty {
                Text("Outros Alertas")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                VStack(spacing: 8) {
                    ForEach(otherAlerts) { alert in
                        AlertCard(alert: alert, style: .normal)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            if alerts.isEmpty {
                EmptyAlertView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
        .background(AppConfiguration.backgroundPrimary)
    }
}

struct AlertCard: View {
    let alert: Alert
    let style: AlertCardStyle

    enum AlertCardStyle {
        case critical, normal
    }

    var body: some View {
        HStack(spacing: 12) {
            // Ícone
            Image(systemName: alert.category.iconName)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(severityColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                    .lineLimit(1)

                Text(alert.description)
                    .font(.system(size: 13))
                    .foregroundStyle(AppConfiguration.textSecondary)
                    .lineLimit(2)

                if let location = alert.location?.address {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(location)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(AppConfiguration.textTertiary)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppConfiguration.textTertiary)
        }
        .padding(12)
        .background(AppConfiguration.backgroundCard)
        .cornerRadius(12)
        .shadow(color: style == .critical ? severityColor.opacity(0.2) : .black.opacity(0.05), radius: 8, y: 2)
    }

    private var severityColor: Color {
        switch alert.severity {
        case .critical: return Color(hex: "DC2626")
        case .high: return AppConfiguration.error
        case .medium: return AppConfiguration.warning
        case .low: return AppConfiguration.primaryBlue
        }
    }
}

struct EmptyAlertView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppConfiguration.success)

            Text("Nenhum alerta ativo")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppConfiguration.textPrimary)

            Text("A cidade está tranquila")
                .font(.system(size: 14))
                .foregroundStyle(AppConfiguration.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppConfiguration.backgroundCard)
        .cornerRadius(12)
    }
}

// Extension para Alert.Category iconName
extension Alert.Category {
    var iconName: String {
        switch self {
        case .weather: return "cloud.bolt.fill"
        case .traffic: return "car.fill"
        case .health: return "cross.fill"
        case .security: return "shield.fill"
        case .infrastructure: return "wrench.fill"
        case .event: return "calendar"
        }
    }
}

#Preview {
    ScrollView {
        AlertasSection(alerts: MockData.alerts)
    }
}
