import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct CidadeVivaApp: App {
    // MARK: - App Delegate

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Services

    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var favoritesUseCase = FavoriteCamerasUseCase.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(notificationService)
                .environmentObject(locationService)
                .environmentObject(favoritesUseCase)
                .onAppear {
                    setupApp()
                }
        }
    }

    // MARK: - Setup

    private func setupApp() {
        // Solicita permissões
        Task {
            // Notificações
            let granted = await notificationService.requestAuthorization()
            if granted {
                // Inscreve em tópicos padrão
                notificationService.subscribeToTopic(NotificationTopic.allAlerts.rawValue)
            }
        }

        // Localização
        locationService.requestAuthorization()
    }
}

// MARK: - App Delegate

/// Delegate para lidar com lifecycle do app e notificações
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configura Firebase
        FirebaseApp.configure()

        // Configura delegate de notificação
        UNUserNotificationCenter.current().delegate = NotificationService.shared

        return true
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Salva token APNS
        NotificationService.shared.setAPNSToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Falha ao registrar para notificações: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Notificação recebida em background
        NotificationService.shared.handleNotification(userInfo)
        completionHandler(.newData)
    }
}
