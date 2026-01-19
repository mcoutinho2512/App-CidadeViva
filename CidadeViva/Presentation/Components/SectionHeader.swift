import SwiftUI

struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    var showSeeAll: Bool = false
    var onSeeAllTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppConfiguration.primaryOrange)
                }

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppConfiguration.textPrimary)
            }

            Spacer()

            if showSeeAll, let action = onSeeAllTap {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text("Ver todos")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(AppConfiguration.primaryBlue)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppConfiguration.backgroundPrimary)
    }
}

#Preview {
    VStack(spacing: 0) {
        SectionHeader(title: "Próximos Eventos", icon: "calendar")
        SectionHeader(title: "Agenda", icon: "list.bullet", showSeeAll: true, onSeeAllTap: {})
    }
}
