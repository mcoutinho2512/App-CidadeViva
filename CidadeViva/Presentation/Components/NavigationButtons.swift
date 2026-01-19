import SwiftUI

struct NavigationShortcut: Identifiable {
    let id: String
    let title: String
    let icon: String
    let colors: [Color]
}

struct NavigationButtonsBar: View {
    @Binding var activeSection: String
    let onTap: (String) -> Void

    private let shortcuts: [NavigationShortcut] = [
        NavigationShortcut(id: "eventos", title: "Eventos", icon: "calendar", colors: [Color(hex: "FF6B95"), Color(hex: "FF8A65")]),
        NavigationShortcut(id: "alertas", title: "Alertas", icon: "bell.fill", colors: [AppConfiguration.error, Color(hex: "FF6B35")]),
        NavigationShortcut(id: "cameras", title: "Câmeras", icon: "video.fill", colors: [Color(hex: "8B5CF6"), AppConfiguration.primaryBlue]),
        NavigationShortcut(id: "mapa", title: "Mapa", icon: "map.fill", colors: [AppConfiguration.primaryBlue, Color(hex: "06B6D4")]),
        NavigationShortcut(id: "transporte", title: "Transporte", icon: "bus.fill", colors: [AppConfiguration.success, Color(hex: "059669")])
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(shortcuts) { shortcut in
                    NavigationShortcutButton(
                        shortcut: shortcut,
                        isActive: activeSection == shortcut.id
                    ) {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        onTap(shortcut.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
}

struct NavigationShortcutButton: View {
    let shortcut: NavigationShortcut
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: shortcut.icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(shortcut.title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isActive {
                        LinearGradient(
                            colors: shortcut.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(
                color: isActive ? shortcut.colors[0].opacity(0.4) : .clear,
                radius: 8,
                y: 4
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isActive)
    }
}

#Preview {
    VStack {
        NavigationButtonsBar(activeSection: .constant("eventos")) { _ in }
        Spacer()
    }
}
