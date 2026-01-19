import SwiftUI

struct EventRowItem: View {
    let event: Event
    var showImage: Bool = false

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: event.startDate)
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: event.startDate).uppercased()
    }

    var body: some View {
        HStack(spacing: 14) {
            // Data Badge com gradiente
            VStack(spacing: 2) {
                Text(dayString)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfiguration.primaryBlue)
                Text(monthString)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(AppConfiguration.primaryBlue.opacity(0.7))
            }
            .frame(width: 48, height: 48)
            .background(AppConfiguration.primaryBlue.opacity(0.1))
            .cornerRadius(10)

            // Info do Evento
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)
                    .lineLimit(1)

                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.system(size: 12))
                        .foregroundStyle(AppConfiguration.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppConfiguration.textTertiary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(AppConfiguration.backgroundCard)
    }
}

#Preview {
    VStack(spacing: 1) {
        EventRowItem(
            event: Event(
                id: UUID(),
                title: "Carnaval de Niterói 2026",
                description: "Desfiles de escolas de samba",
                category: .cultural,
                location: Location(latitude: -7.1195, longitude: -34.8761),
                startDate: Date(),
                endDate: nil,
                imageURL: nil,
                organizer: nil,
                isFree: true,
                price: nil
            )
        )
        EventRowItem(
            event: Event(
                id: UUID(),
                title: "Festa Junina no Horto do Fonseca",
                description: "Festa tradicional com quadrilha",
                category: .cultural,
                location: Location(latitude: -7.1195, longitude: -34.8761),
                startDate: Date().addingTimeInterval(86400 * 30),
                endDate: nil,
                imageURL: nil,
                organizer: nil,
                isFree: true,
                price: nil
            )
        )
    }
    .background(AppConfiguration.backgroundPrimary)
}
