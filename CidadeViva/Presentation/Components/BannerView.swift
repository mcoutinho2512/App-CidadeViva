import SwiftUI

struct BannerView: View {
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private let bannerItems: [BannerItem] = [
        BannerItem(icon: "building.2.fill", title: "Centro Histórico", subtitle: "Conheça nossa história"),
        BannerItem(icon: "leaf.fill", title: "Parques", subtitle: "Áreas verdes da cidade"),
        BannerItem(icon: "figure.walk", title: "Praças", subtitle: "Lazer ao ar livre"),
        BannerItem(icon: "building.columns.fill", title: "Cultura", subtitle: "Museus e teatros")
    ]

    var body: some View {
        ZStack {
            // Background com gradiente
            AppConfiguration.gradientOcean

            // Conteúdo
            TabView(selection: $currentIndex) {
                ForEach(0..<bannerItems.count, id: \.self) { index in
                    BannerSlideView(item: bannerItems[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Indicadores customizados com blur
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<bannerItems.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: index == currentIndex ? 24 : 8, height: 8)
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .padding(.bottom, 16)
                .animation(.spring(response: 0.3), value: currentIndex)
            }
        }
        .frame(height: 180)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % bannerItems.count
            }
        }
    }
}

struct BannerItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct BannerSlideView: View {
    let item: BannerItem

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: item.icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.white.opacity(0.9))

            Text(item.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text(item.subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

#Preview {
    BannerView()
}
