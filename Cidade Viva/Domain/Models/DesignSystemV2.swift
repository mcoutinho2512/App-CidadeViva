//
//  DesignSystemV2.swift
//  CidadeViva
//
//  Sistema de Design Premium - Futurista e Moderno
//  Inspirado em: Apple Weather, Stripe, Arc Browser, Linear
//

import SwiftUI

// MARK: - 🎨 Color Palette

extension Color {
    
    // MARK: Backgrounds
    static let backgroundDark = Color(hex: "0A0E27")
    static let backgroundCard = Color(hex: "141B34")
    
    // MARK: Primary Colors
    static let primaryStart = Color(hex: "667EEA")
    static let primaryEnd = Color(hex: "764BA2")
    
    // MARK: Secondary Colors
    static let secondaryStart = Color(hex: "F093FB")
    static let secondaryEnd = Color(hex: "F5576C")
    
    // MARK: Accent & Status
    static let accentCyan = Color(hex: "00D9FF")
    static let successNeon = Color(hex: "00E5B8")
    static let warningGold = Color(hex: "FFB800")
    static let errorVibrant = Color(hex: "FF3B6D")
    
    // MARK: Text
    static let textPrimary = Color(hex: "FFFFFF")
    static let textSecondary = Color(hex: "A0AEC0")
    
    // MARK: Gradient Colors
    static let sunriseStart = Color(hex: "FF6B95")
    static let sunriseEnd = Color(hex: "FFA94D")
    
    static let oceanStart = Color(hex: "667EEA")
    static let oceanEnd = Color(hex: "00D9FF")
    
    static let forestStart = Color(hex: "00E5B8")
    static let forestEnd = Color(hex: "667EEA")
    
    static let fireStart = Color(hex: "FF3B6D")
    static let fireEnd = Color(hex: "FFA94D")
    
    // MARK: Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 🌈 Gradient Presets

extension LinearGradient {
    
    static let primary = LinearGradient(
        colors: [.primaryStart, .primaryEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondary = LinearGradient(
        colors: [.secondaryStart, .secondaryEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunrise = LinearGradient(
        colors: [.sunriseStart, .sunriseEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let ocean = LinearGradient(
        colors: [.oceanStart, .oceanEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let forest = LinearGradient(
        colors: [.forestStart, .forestEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let fire = LinearGradient(
        colors: [.fireStart, .fireEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - ✨ Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = 24
    var cornerRadius: CGFloat = 32
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Glass effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .floatingShadow()
    }
}

// MARK: - 🎭 Floating Shadow Modifier

struct FloatingShadowModifier: ViewModifier {
    var intensity: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: .black.opacity(0.3 * intensity),
                radius: 20 * intensity,
                x: 0,
                y: 10 * intensity
            )
            .shadow(
                color: .black.opacity(0.15 * intensity),
                radius: 30 * intensity,
                x: 0,
                y: 15 * intensity
            )
    }
}

// MARK: - 🌊 Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .clipped()
            )
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

// MARK: - 💫 Bounce Press Modifier

struct BouncePressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - 🎬 Staggered Appearance Modifier

struct StaggeredAppearanceModifier: ViewModifier {
    let index: Int
    let delay: Double = 0.1
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * delay)
                ) {
                    appeared = true
                }
            }
    }
}

// MARK: - ✨ Glow Effect Modifier

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 1.5, x: 0, y: 0)
    }
}

// MARK: - 🎯 Pulsing Modifier

struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false
    var minScale: CGFloat = 0.95
    var maxScale: CGFloat = 1.05
    var duration: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - 🎨 Gradient Background Modifier

struct GradientBackgroundModifier: ViewModifier {
    var gradient: LinearGradient
    
    func body(content: Content) -> some View {
        ZStack {
            gradient.ignoresSafeArea()
            content
        }
    }
}

// MARK: - 📊 Animated Counter View

struct AnimatedCounter: View {
    let value: Int
    let duration: Double = 0.8
    
    @State private var displayedValue: Int = 0
    
    var body: some View {
        Text("\(displayedValue)")
            .contentTransition(.numericText(value: Double(displayedValue)))
            .onAppear {
                animateCounter()
            }
            .onChange(of: value) { oldValue, newValue in
                animateCounter()
            }
    }
    
    private func animateCounter() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            displayedValue = value
        }
    }
}

// MARK: - 📈 Animated Double Counter View

struct AnimatedDoubleCounter: View {
    let value: Double
    let format: String
    let duration: Double = 0.8
    
    @State private var displayedValue: Double = 0
    
    init(value: Double, format: String = "%.1f") {
        self.value = value
        self.format = format
    }
    
    var body: some View {
        Text(String(format: format, displayedValue))
            .contentTransition(.numericText(value: displayedValue))
            .onAppear {
                animateCounter()
            }
            .onChange(of: value) { oldValue, newValue in
                animateCounter()
            }
    }
    
    private func animateCounter() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            displayedValue = value
        }
    }
}

// MARK: - View Extensions

extension View {
    
    /// Aplica estilo de glass card
    func glassCard(padding: CGFloat = 24, cornerRadius: CGFloat = 32) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
    
    /// Aplica sombra flutuante
    func floatingShadow(intensity: CGFloat = 1.0) -> some View {
        modifier(FloatingShadowModifier(intensity: intensity))
    }
    
    /// Aplica efeito shimmer
    func shimmer(duration: Double = 1.5) -> some View {
        modifier(ShimmerModifier(duration: duration))
    }
    
    /// Aplica animação de bounce ao tocar
    func bouncePress() -> some View {
        modifier(BouncePressModifier())
    }
    
    /// Aplica aparição staggered
    func staggeredAppearance(index: Int) -> some View {
        modifier(StaggeredAppearanceModifier(index: index))
    }
    
    /// Aplica efeito de glow
    func glow(color: Color, radius: CGFloat = 20) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
    
    /// Aplica animação pulsante
    func pulsing(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1.0) -> some View {
        modifier(PulsingModifier(minScale: minScale, maxScale: maxScale, duration: duration))
    }
    
    /// Aplica gradiente de fundo
    func gradientBackground(_ gradient: LinearGradient) -> some View {
        modifier(GradientBackgroundModifier(gradient: gradient))
    }
    
    /// Adiciona padding extra para TabBar (corrige scroll cortado)
    func tabBarSafeAreaPadding() -> some View {
        self.padding(.bottom, 80)
    }
}

// MARK: - 🎭 Typography System

extension Font {
    
    // Display / Hero
    static let displayHero = Font.system(size: 64, weight: .bold, design: .default)
        .leading(.tight)
    
    // Titles
    static let title1Custom = Font.system(size: 34, weight: .bold, design: .default)
    static let title2Custom = Font.system(size: 28, weight: .semibold, design: .default)
    static let title3Custom = Font.system(size: 22, weight: .semibold, design: .default)
    
    // Body
    static let bodyCustom = Font.system(size: 17, weight: .regular, design: .default)
    
    // Caption & Labels
    static let captionCustom = Font.system(size: 13, weight: .medium, design: .default)
    static let labelCustom = Font.system(size: 11, weight: .semibold, design: .default)
    
    // Numbers (Rounded)
    static let numberLarge = Font.system(size: 80, weight: .bold, design: .rounded)
    static let numberMedium = Font.system(size: 48, weight: .semibold, design: .rounded)
    static let numberSmall = Font.system(size: 24, weight: .medium, design: .rounded)
}

// MARK: - 📏 Spacing System

enum Spacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    
    // Card specific
    static let cardPadding: CGFloat = 24
    static let cardSpacing: CGFloat = 16
    static let cardRadius: CGFloat = 32
    
    // Margins
    static let screenPadding: CGFloat = 20
}

// MARK: - 🎯 Animation Presets

extension Animation {
    
    static let smooth = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let quick = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let gentle = Animation.spring(response: 0.8, dampingFraction: 0.9)
}

// MARK: - 🌡️ Weather Gradient Helper

extension LinearGradient {
    
    static func forWeatherCondition(_ condition: String) -> LinearGradient {
        let lowercased = condition.lowercased()
        
        if lowercased.contains("sol") || lowercased.contains("sunny") || lowercased.contains("clear") {
            return .sunrise
        } else if lowercased.contains("chuva") || lowercased.contains("rain") {
            return .ocean
        } else if lowercased.contains("nublado") || lowercased.contains("cloud") {
            return LinearGradient(
                colors: [Color(hex: "696E79"), Color(hex: "414750")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if lowercased.contains("tempestade") || lowercased.contains("storm") {
            return .fire
        } else {
            return .primary
        }
    }
}

// MARK: - 🎨 Status Color Helper

extension Color {
    
    static func forAlertSeverity(_ severity: String) -> Color {
        let lowercased = severity.lowercased()
        
        if lowercased.contains("high") || lowercased.contains("alta") || lowercased.contains("crítico") {
            return .errorVibrant
        } else if lowercased.contains("medium") || lowercased.contains("média") {
            return .warningGold
        } else {
            return .successNeon
        }
    }
}
