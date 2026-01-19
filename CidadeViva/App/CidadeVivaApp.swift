import SwiftUI
import FirebaseCore

@main
struct CidadeVivaApp: App {

    init() {
        // Inicializa o Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
        }
    }
}
