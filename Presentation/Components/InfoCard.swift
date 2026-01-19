//
//  InfoCard.swift
//  CidadeViva
//
//  Card genérico de informação reutilizável
//

import SwiftUI

/// Card de informação genérico
struct InfoCard: View {

    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let iconColor: Color
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        iconColor: Color = Color("PrimaryColor"),
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                // Ícone
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(iconColor)
                    .frame(width: 50, height: 50)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(10)

                // Conteúdo
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Chevron se tiver ação
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoCard(
            icon: "thermometer",
            title: "Temperatura",
            value: "28°",
            subtitle: "Sensação: 30°",
            iconColor: .orange
        )

        InfoCard(
            icon: "video.fill",
            title: "Câmeras Online",
            value: "24",
            subtitle: "6 offline",
            iconColor: Color("SecondaryColor"),
            action: {}
        )

        InfoCard(
            icon: "exclamationmark.triangle.fill",
            title: "Alertas Ativos",
            value: "5",
            subtitle: "2 críticos",
            iconColor: Color("AlertColor"),
            action: {}
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
