import SwiftUI

struct ErrorView: View {
    var message: String = "Ocorreu um erro"
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let retryAction = retryAction {
                Button {
                    retryAction()
                } label: {
                    Label("Tentar novamente", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(message: "Erro ao carregar dados") {
        print("Retry tapped")
    }
}
