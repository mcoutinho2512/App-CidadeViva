//
//  ErrorView.swift
//  CidadeViva
//
//  View de erro genérica com retry
//

import SwiftUI

/// View de erro padrão do app
struct ErrorView: View {

    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("AlertColor"))

            VStack(spacing: 8) {
                Text("Ops! Algo deu errado")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let networkError = error as? NetworkError,
                   let suggestion = networkError.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                }
            }

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Tentar Novamente")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color("PrimaryColor"))
                .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    ErrorView(
        error: NetworkError.noInternetConnection,
        retryAction: {}
    )
}
