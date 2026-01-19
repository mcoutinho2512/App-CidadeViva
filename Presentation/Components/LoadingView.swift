//
//  LoadingView.swift
//  CidadeViva
//
//  View de carregamento genérica
//

import SwiftUI

/// View de loading padrão do app
struct LoadingView: View {

    let message: String

    init(message: String = "Carregando...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryColor")))

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    LoadingView()
}
