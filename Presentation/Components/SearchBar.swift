//
//  SearchBar.swift
//  CidadeViva
//
//  Componente de barra de busca reutilizável
//

import SwiftUI

struct SearchBar: View {

    // MARK: - Properties

    @Binding var text: String
    var placeholder: String = "Buscar..."
    var onSearchButtonClicked: (() -> Void)? = nil

    // MARK: - State

    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            // Text Field
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    onSearchButtonClicked?()
                }

            // Clear Button
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBar(text: .constant(""), placeholder: "Buscar...")
            SearchBar(text: .constant("Texto de busca"), placeholder: "Buscar...")
        }
        .padding()
    }
}
