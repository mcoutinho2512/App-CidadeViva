import SwiftUI

struct EventCardLarge: View {
    let event: Event
    let style: CardStyle

    enum CardStyle {
        case sunset
        case ocean

        var gradient: LinearGradient {
            switch self {
            case .sunset: return AppConfiguration.gradientSunset
            case .ocean: return AppConfiguration.gradientOcean
            }
        }
    }

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
        VStack(alignment: .leading, spacing: 8) {
            // Data
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(dayString)
                    .font(.system(size: 32, weight: .bold))
                Text(monthString)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)

            Spacer()

            // Título
            Text(event.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            // Descrição
            Text(event.description)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(style.gradient)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

#Preview {
    HStack(spacing: 12) {
        EventCardLarge(
            event: Event(
                id: UUID(),
                title: "Carnaval de Niterói",
                description: "Desfiles de escolas de samba e blocos de rua.",
                category: .cultural,
                location: Location(latitude: -7.1195, longitude: -34.8761),
                startDate: Date(),
                endDate: nil,
                imageURL: nil,
                organizer: nil,
                isFree: true,
                price: nil
            ),
            style: .ocean
        )

        EventCardLarge(
            event: Event(
                id: UUID(),
                title: "Festa Junina",
                description: "Tradicional festa com quadrilhas e comidas típicas.",
                category: .cultural,
                location: Location(latitude: -7.1195, longitude: -34.8761),
                startDate: Date(),
                endDate: nil,
                imageURL: nil,
                organizer: nil,
                isFree: true,
                price: nil
            ),
            style: .sunset
        )
    }
    .padding()
}
