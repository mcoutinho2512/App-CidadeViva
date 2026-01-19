import SwiftUI

struct TransporteSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da seção
            HStack(spacing: 12) {
                Image(systemName: "bus.fill")
                    .font(.system(size: 24))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppConfiguration.success, Color(hex: "059669"))

                Text("Transporte Público")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)

            // Cards de transporte
            VStack(spacing: 12) {
                TransportOptionCard(
                    icon: "bus.fill",
                    title: "Ônibus",
                    subtitle: "45 linhas ativas",
                    color: AppConfiguration.success
                )

                TransportOptionCard(
                    icon: "ferry.fill",
                    title: "Barcas",
                    subtitle: "Niterói - Rio",
                    color: AppConfiguration.primaryBlue
                )

                TransportOptionCard(
                    icon: "bicycle",
                    title: "Bike Niterói",
                    subtitle: "32 estações",
                    color: AppConfiguration.primaryOrange
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)

            // Em breve
            VStack(spacing: 12) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 32))
                    .foregroundStyle(AppConfiguration.textTertiary)

                Text("Mais informações em breve")
                    .font(.system(size: 14))
                    .foregroundStyle(AppConfiguration.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.bottom, 40)
        }
        .background(AppConfiguration.backgroundPrimary)
    }
}

struct TransportOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppConfiguration.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppConfiguration.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppConfiguration.textTertiary)
        }
        .padding(14)
        .background(AppConfiguration.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    ScrollView {
        TransporteSection()
    }
}
