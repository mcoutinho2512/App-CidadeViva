//
//  CardStyle.swift
//  CidadeViva
//
//  Estilos reutilizáveis de cards
//

import SwiftUI

/// Modificador de view para estilo de card padrão
struct CardModifier: ViewModifier {

    let backgroundColor: Color
    let shadowRadius: CGFloat

    init(
        backgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground),
        shadowRadius: CGFloat = AppConfiguration.UI.cardShadowRadius
    ) {
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(AppConfiguration.UI.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    /// Aplica estilo de card
    func cardStyle(
        backgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground),
        shadowRadius: CGFloat = AppConfiguration.UI.cardShadowRadius
    ) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor, shadowRadius: shadowRadius))
    }
}
