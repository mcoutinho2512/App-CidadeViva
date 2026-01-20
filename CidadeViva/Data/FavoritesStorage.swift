import Foundation

/// Protocolo para persistência de favoritos
protocol FavoritesStorageProtocol {
    /// Carrega IDs de câmeras favoritas
    func loadFavorites() -> [UUID]

    /// Salva IDs de câmeras favoritas
    func saveFavorites(_ ids: [UUID])

    /// Limpa todos os favoritos
    func clearFavorites()
}

/// Implementação de persistência de favoritos usando UserDefaults
final class FavoritesStorage: FavoritesStorageProtocol {
    // MARK: - Singleton

    static let shared = FavoritesStorage()

    // MARK: - Constants

    private enum Keys {
        static let favoriteCameras = "favorite_cameras"
        static let favoriteAlerts = "favorite_alerts"
        static let favoriteEvents = "favorite_events"
        static let favoriteNews = "favorite_news"
    }

    // MARK: - Dependencies

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - FavoritesStorageProtocol

    func loadFavorites() -> [UUID] {
        guard let data = defaults.data(forKey: Keys.favoriteCameras),
              let uuidStrings = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }

        return uuidStrings.compactMap { UUID(uuidString: $0) }
    }

    func saveFavorites(_ ids: [UUID]) {
        let uuidStrings = ids.map { $0.uuidString }

        if let data = try? JSONEncoder().encode(uuidStrings) {
            defaults.set(data, forKey: Keys.favoriteCameras)
        }
    }

    func clearFavorites() {
        defaults.removeObject(forKey: Keys.favoriteCameras)
    }

    // MARK: - Generic Methods

    /// Carrega favoritos para qualquer tipo de item
    func loadFavorites(for key: String) -> [UUID] {
        guard let data = defaults.data(forKey: key),
              let uuidStrings = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }

        return uuidStrings.compactMap { UUID(uuidString: $0) }
    }

    /// Salva favoritos para qualquer tipo de item
    func saveFavorites(_ ids: [UUID], for key: String) {
        let uuidStrings = ids.map { $0.uuidString }

        if let data = try? JSONEncoder().encode(uuidStrings) {
            defaults.set(data, forKey: key)
        }
    }

    /// Verifica se um item é favorito
    func isFavorite(id: UUID, for key: String) -> Bool {
        let favorites = loadFavorites(for: key)
        return favorites.contains(id)
    }

    /// Adiciona item aos favoritos
    func addFavorite(id: UUID, for key: String) {
        var favorites = loadFavorites(for: key)
        guard !favorites.contains(id) else { return }
        favorites.append(id)
        saveFavorites(favorites, for: key)
    }

    /// Remove item dos favoritos
    func removeFavorite(id: UUID, for key: String) {
        var favorites = loadFavorites(for: key)
        favorites.removeAll { $0 == id }
        saveFavorites(favorites, for: key)
    }

    /// Alterna favorito
    func toggleFavorite(id: UUID, for key: String) -> Bool {
        if isFavorite(id: id, for: key) {
            removeFavorite(id: id, for: key)
            return false
        } else {
            addFavorite(id: id, for: key)
            return true
        }
    }
}

// MARK: - Specialized Storage Classes

/// Storage para alertas favoritos
final class FavoriteAlertsStorage: FavoritesStorageProtocol {
    static let shared = FavoriteAlertsStorage()

    private let storage = FavoritesStorage.shared
    private let key = "favorite_alerts"

    func loadFavorites() -> [UUID] {
        storage.loadFavorites(for: key)
    }

    func saveFavorites(_ ids: [UUID]) {
        storage.saveFavorites(ids, for: key)
    }

    func clearFavorites() {
        storage.saveFavorites([], for: key)
    }
}

/// Storage para eventos favoritos
final class FavoriteEventsStorage: FavoritesStorageProtocol {
    static let shared = FavoriteEventsStorage()

    private let storage = FavoritesStorage.shared
    private let key = "favorite_events"

    func loadFavorites() -> [UUID] {
        storage.loadFavorites(for: key)
    }

    func saveFavorites(_ ids: [UUID]) {
        storage.saveFavorites(ids, for: key)
    }

    func clearFavorites() {
        storage.saveFavorites([], for: key)
    }
}

/// Storage para notícias favoritas
final class FavoriteNewsStorage: FavoritesStorageProtocol {
    static let shared = FavoriteNewsStorage()

    private let storage = FavoritesStorage.shared
    private let key = "favorite_news"

    func loadFavorites() -> [UUID] {
        storage.loadFavorites(for: key)
    }

    func saveFavorites(_ ids: [UUID]) {
        storage.saveFavorites(ids, for: key)
    }

    func clearFavorites() {
        storage.saveFavorites([], for: key)
    }
}

// MARK: - App Settings Storage

/// Storage para configurações do app
final class AppSettingsStorage {
    static let shared = AppSettingsStorage()

    private let defaults: UserDefaults

    private enum Keys {
        static let notificationsEnabled = "notifications_enabled"
        static let notificationTopics = "notification_topics"
        static let lastOpenedTab = "last_opened_tab"
        static let mapZoomLevel = "map_zoom_level"
        static let showOnlyOnlineCameras = "show_only_online_cameras"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Notifications

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }

    var subscribedTopics: [String] {
        get { defaults.stringArray(forKey: Keys.notificationTopics) ?? [] }
        set { defaults.set(newValue, forKey: Keys.notificationTopics) }
    }

    // MARK: - UI Preferences

    var lastOpenedTab: Int {
        get { defaults.integer(forKey: Keys.lastOpenedTab) }
        set { defaults.set(newValue, forKey: Keys.lastOpenedTab) }
    }

    var mapZoomLevel: Double {
        get {
            let value = defaults.double(forKey: Keys.mapZoomLevel)
            return value > 0 ? value : 0.05 // Default zoom
        }
        set { defaults.set(newValue, forKey: Keys.mapZoomLevel) }
    }

    var showOnlyOnlineCameras: Bool {
        get { defaults.bool(forKey: Keys.showOnlyOnlineCameras) }
        set { defaults.set(newValue, forKey: Keys.showOnlyOnlineCameras) }
    }

    // MARK: - Reset

    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
    }
}
