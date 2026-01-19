import SwiftUI

struct ShortcutItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
}

struct ShortcutsBar: View {
    let shortcuts: [ShortcutItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(shortcuts) { shortcut in
                    ShortcutButton(item: shortcut)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct ShortcutButton: View {
    let item: ShortcutItem

    var body: some View {
        Button(action: item.action) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [item.color, item.color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: item.color.opacity(0.3), radius: 6, y: 3)
        }
    }
}

#Preview {
    ShortcutsBar(shortcuts: [
        ShortcutItem(title: "Mapa", icon: "map", color: AppConfiguration.primaryBlue, action: {}),
        ShortcutItem(title: "Rotas", icon: "location.fill", color: AppConfiguration.primaryOrange, action: {}),
        ShortcutItem(title: "Transporte", icon: "bus.fill", color: AppConfiguration.success, action: {}),
        ShortcutItem(title: "Eventos", icon: "calendar", color: Color(hex: "FF6B95"), action: {})
    ])
}
