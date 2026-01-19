import SwiftUI

struct EventosSection: View {
    let events: [Event]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da seção
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(hex: "FF6B95"), Color(hex: "FF8A65"))

                Text("Próximos Eventos")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()

                Text("\(events.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FF6B95"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Lista de eventos
            VStack(spacing: 1) {
                ForEach(events.prefix(6)) { event in
                    EventRowItem(event: event)
                }
            }

            // Ver todos
            if events.count > 6 {
                Button {
                    // Ação ver todos
                } label: {
                    HStack {
                        Text("Ver todos os eventos")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(AppConfiguration.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(AppConfiguration.backgroundPrimary)
    }
}

#Preview {
    ScrollView {
        EventosSection(events: MockData.events)
    }
}
