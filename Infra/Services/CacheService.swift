//
//  CacheService.swift
//  CidadeViva
//
//  Serviço de cache em memória para dados temporários
//

import Foundation

/// Serviço de cache genérico em memória
final class CacheService {

    // MARK: - Singleton

    static let shared = CacheService()

    // MARK: - Properties

    private var cache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "com.cidadeviva.cache", attributes: .concurrent)
    private let expirationTime: TimeInterval

    // MARK: - Initialization

    private init(expirationTime: TimeInterval = AppConfiguration.Cache.expirationTime) {
        self.expirationTime = expirationTime
    }

    // MARK: - Public Methods

    /// Salva um objeto no cache
    func set<T>(_ object: T, forKey key: String) {
        queue.async(flags: .barrier) {
            let entry = CacheEntry(
                value: object,
                expirationDate: Date().addingTimeInterval(self.expirationTime)
            )
            self.cache[key] = entry
        }
    }

    /// Recupera um objeto do cache
    func get<T>(forKey key: String) -> T? {
        var entry: CacheEntry?

        queue.sync {
            entry = cache[key]
        }

        guard let entry = entry else {
            return nil
        }

        // Verifica se está expirado
        if Date() > entry.expirationDate {
            remove(forKey: key)
            return nil
        }

        return entry.value as? T
    }

    /// Remove um objeto do cache
    func remove(forKey key: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }

    /// Limpa todo o cache
    func clearAll() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }

    /// Remove itens expirados do cache
    func cleanExpired() {
        queue.async(flags: .barrier) {
            let now = Date()
            self.cache = self.cache.filter { $0.value.expirationDate > now }
        }
    }
}

// MARK: - Cache Entry

private struct CacheEntry {
    let value: Any
    let expirationDate: Date
}

// MARK: - Cache Keys

extension CacheService {

    /// Chaves de cache predefinidas
    enum CacheKey {
        static let weather = "cache.weather"
        static let cameras = "cache.cameras"
        static let alerts = "cache.alerts"
        static let events = "cache.events"
        static let news = "cache.news"
        static let pois = "cache.pois"
    }
}
