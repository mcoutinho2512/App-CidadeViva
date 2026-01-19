import SwiftUI

struct BannerView: View {
    @State private var currentIndex = 0
    @State private var banners: [Banner] = []
    @State private var isLoading = true
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background com gradiente
            AppConfiguration.gradientOcean

            if isLoading {
                // Loading
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if banners.isEmpty {
                // Fallback quando não há banners
                VStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("Cidade Viva")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Sua cidade na palma da mão")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            } else {
                // Conteúdo com banners do Firebase
                TabView(selection: $currentIndex) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        BannerSlideView(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                // Indicadores customizados com blur
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<banners.count, id: \.self) { index in
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
        }
        .frame(height: 180)
        .onReceive(timer) { _ in
            guard !banners.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
        .task {
            await loadBanners()
        }
    }

    private func loadBanners() async {
        do {
            let fetchedBanners = try await FirestoreService.shared.fetchBanners()
            print("✅ Banners carregados: \(fetchedBanners.count)")
            for banner in fetchedBanners {
                print("  - \(banner.title): \(banner.imageURL?.absoluteString ?? "sem imagem")")
            }
            await MainActor.run {
                self.banners = fetchedBanners
                self.isLoading = false
            }
        } catch {
            print("❌ Erro ao carregar banners: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

struct BannerSlideView: View {
    let banner: Banner

    var body: some View {
        ZStack {
            // Background gradiente como fallback
            AppConfiguration.gradientOcean

            // Imagem de fundo
            if let imageURL = banner.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(let error):
                        // Fallback quando imagem falha
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .onAppear {
                            print("❌ Falha ao carregar imagem: \(imageURL.absoluteString) - \(error)")
                        }
                    @unknown default:
                        Color.clear
                    }
                }
            }

            // Overlay gradiente para legibilidade do texto
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Texto
            VStack(spacing: 8) {
                Spacer()

                Text(banner.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                Text(banner.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .clipped()
    }
}

#Preview {
    BannerView()
}
