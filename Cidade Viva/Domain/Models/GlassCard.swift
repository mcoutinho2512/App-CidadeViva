//
//  GlassCard.swift
//  CidadeViva
//
//  Card premium com efeito glassmorphism e animações
//

import SwiftUI

/// Card premium com efeito de vidro fosco e animações fluidas
struct GlassCard: View {
    
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let gradient: LinearGradient
    let action: (() -> Void)?
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        gradient: LinearGradient = .primary,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.gradient = gradient
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: Spacing.lg) {
                // Ícone com gradiente e glow
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 64, height: 64)
                        .glow(color: Color.primaryStart, radius: 15)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: isPressed)
                }
                
                // Conteúdo
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.captionCustom)
                        .foregroundStyle(Color.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    // Valor animado
                    Text(value)
                        .font(.numberMedium)
                        .foregroundStyle(Color.textPrimary)
                        .contentTransition(.numericText())
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.captionCustom)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron se tiver ação
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(.bouncy, value: isPressed)
                }
            }
            .padding(Spacing.xl)
            .glassCard(padding: 0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.bouncy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.bouncy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.bouncy) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Mini Glass Card (para stats)

struct MiniGlassCard: View {
    
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .glow(color: color, radius: 10)
            }
            
            AnimatedCounter(value: Int(value) ?? 0)
                .font(.title2Custom)
                .foregroundStyle(Color.textPrimary)
            
            Text(label)
                .font(.captionCustom)
                .foregroundStyle(Color.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.smooth.delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Hero Weather Glass Card

struct HeroWeatherCard: View {
    
    let weather: Weather
    
    @State private var appeared = false
    @State private var iconRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Gradiente de fundo baseado na condição
            LinearGradient.forWeatherCondition(weather.condition.rawValue)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.cardRadius))
            
            // Overlay de vidro
            RoundedRectangle(cornerRadius: Spacing.cardRadius)
                .fill(.ultraThinMaterial)
            
            VStack(spacing: Spacing.xl) {
                // Localização
                Text(weather.location)
                    .font(.title3Custom)
                    .foregroundStyle(Color.textSecondary)
                
                // Ícone animado
                Image(systemName: weather.condition.iconName)
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating)
                    .shadow(color: .white.opacity(0.5), radius: 20)
                    .rotationEffect(.degrees(iconRotation))
                
                // Temperatura gigante
                HStack(alignment: .top, spacing: 4) {
                    AnimatedDoubleCounter(value: weather.temperature, format: "%.0f")
                        .font(.numberLarge)
                        .foregroundStyle(.white)
                    
                    Text("°")
                        .font(.numberLarge)
                        .foregroundStyle(.white.opacity(0.7))
                        .offset(y: 8)
                }
                
                // Condição
                Text(weather.condition.description)
                    .font(.title2Custom)
                    .foregroundStyle(.white)
                
                // Sensação térmica
                Text(weather.feelsLikeFormatted)
                    .font(.title3Custom)
                    .foregroundStyle(.white.opacity(0.8))
                
                Divider()
                    .background(.white.opacity(0.3))
                    .padding(.vertical, Spacing.sm)
                
                // Detalhes em grid
                HStack(spacing: Spacing.xxxl) {
                    weatherDetail(
                        icon: "humidity.fill",
                        label: "Umidade",
                        value: weather.humidityFormatted
                    )
                    
                    weatherDetail(
                        icon: "wind",
                        label: "Vento",
                        value: weather.windSpeedFormatted
                    )
                }
            }
            .padding(Spacing.xxxl)
        }
        .floatingShadow(intensity: 1.5)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.9)
        .onAppear {
            withAnimation(.smooth) {
                appeared = true
            }
            
            // Rotação sutil do ícone
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
        }
    }
    
    private func weatherDetail(icon: String, label: String, value: String) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
            
            Text(value)
                .font(.title3Custom)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.captionCustom)
                .foregroundStyle(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(0.5)
        }
    }
}

// MARK: - Camera Status Card

struct CameraStatusCard: View {
    
    let camera: Camera
    
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Status indicator pulsante
            ZStack {
                if camera.isActive {
                    Circle()
                        .fill(Color.successNeon.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .scaleEffect(pulseAnimation ? 1.4 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }
                
                Circle()
                    .fill(Color.forAlertSeverity(camera.statusText))
                    .frame(width: 16, height: 16)
                    .glow(
                        color: Color.forAlertSeverity(camera.statusText),
                        radius: camera.isActive ? 10 : 5
                    )
            }
            .frame(width: 24, height: 24)
            .onAppear {
                if camera.isActive {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        pulseAnimation = true
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(camera.name)
                    .font(.title3Custom)
                    .foregroundStyle(Color.textPrimary)
                
                HStack(spacing: Spacing.md) {
                    Label(camera.region, systemImage: "mappin.circle.fill")
                        .font(.captionCustom)
                        .foregroundStyle(Color.textSecondary)
                    
                    Label(camera.statusText, systemImage: camera.status.iconName)
                        .font(.captionCustom)
                        .foregroundStyle(Color.forAlertSeverity(camera.statusText))
                }
            }
            
            Spacer()
            
            if camera.isActive {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentCyan, Color.primaryStart],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .glow(color: Color.accentCyan, radius: 15)
            }
        }
        .padding(Spacing.lg)
        .glassCard()
        .bouncePress()
    }
}

// MARK: - Alert Card Premium

struct AlertCardPremium: View {
    
    let alert: Alert
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Header com tipo e badge de severidade
            HStack {
                Label(alert.type.description, systemImage: alert.type.iconName)
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                severityBadge
            }
            
            // Título
            Text(alert.title)
                .font(.title3Custom)
                .foregroundStyle(Color.textPrimary)
            
            // Descrição
            Text(alert.description)
                .font(.bodyCustom)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(3)
            
            // Footer
            HStack {
                Label(alert.location, systemImage: "mappin.circle.fill")
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Text(alert.createdAtFormatted)
                    .font(.captionCustom)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(Spacing.xl)
        .glassCard(padding: 0)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.cardRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.forAlertSeverity(alert.severity.rawValue),
                            Color.forAlertSeverity(alert.severity.rawValue).opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .glow(color: Color.forAlertSeverity(alert.severity.rawValue), radius: 10)
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.smooth.delay(0.05)) {
                appeared = true
            }
        }
    }
    
    private var severityBadge: some View {
        Text(alert.severity.description.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.forAlertSeverity(alert.severity.rawValue),
                                Color.forAlertSeverity(alert.severity.rawValue).opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .glow(color: Color.forAlertSeverity(alert.severity.rawValue), radius: 8)
    }
}

// MARK: - Preview

#Preview("Glass Cards") {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: Spacing.lg) {
                GlassCard(
                    icon: "camera.fill",
                    title: "Câmeras de Monitoramento",
                    value: "24",
                    subtitle: "câmeras disponíveis",
                    gradient: .ocean,
                    action: {}
                )
                
                GlassCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Alertas Ativos",
                    value: "5",
                    subtitle: "requerem atenção",
                    gradient: .fire
                )
                
                HStack(spacing: Spacing.md) {
                    MiniGlassCard(
                        icon: "checkmark.circle.fill",
                        value: "18",
                        label: "Online",
                        color: .successNeon
                    )
                    
                    MiniGlassCard(
                        icon: "xmark.circle.fill",
                        value: "6",
                        label: "Offline",
                        color: .errorVibrant
                    )
                }
            }
            .padding()
        }
    }
}
