import SwiftUI

struct HeaderView: View {
    @Binding var showLanguageSelector: Bool
    var alertCount: Int = 0
    var onAlertsTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Logo com ícone
            HStack(spacing: 10) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppConfiguration.primaryOrange, AppConfiguration.primaryBlue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cidade Viva")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Niterói, RJ")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Spacer()

            // Ações
            HStack(spacing: 16) {
                // Idioma
                Button {
                    showLanguageSelector = true
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }

                // Notificações
                Button(action: onAlertsTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))

                        if alertCount > 0 {
                            Text("\(min(alertCount, 9))")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 16, height: 16)
                                .background(AppConfiguration.error)
                                .clipShape(Circle())
                                .offset(x: 8, y: -6)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 54)
        .padding(.bottom, 14)
        .background(AppConfiguration.backgroundDark)
    }
}

#Preview {
    VStack(spacing: 0) {
        HeaderView(
            showLanguageSelector: .constant(false),
            alertCount: 3,
            onAlertsTap: {}
        )
        Spacer()
    }
    .ignoresSafeArea()
}
