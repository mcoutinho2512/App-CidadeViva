import Foundation

final class CacheService {
    static let shared = CacheService()
    private let cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    // MARK: - Memory Cache

    func set<T: AnyObject>(_ object: T, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
    }

    func get<T: AnyObject>(forKey key: String) -> T? {
        cache.object(forKey: key as NSString) as? T
    }

    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func clearMemoryCache() {
        cache.removeAllObjects()
    }

    // MARK: - Disk Cache

    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }

    func saveToDisk<T: Encodable>(_ object: T, forKey key: String) throws {
        guard let directory = cacheDirectory else { return }
        let fileURL = directory.appendingPathComponent(key)
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL)
    }

    func loadFromDisk<T: Decodable>(forKey key: String) throws -> T? {
        guard let directory = cacheDirectory else { return nil }
        let fileURL = directory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func removeFromDisk(forKey key: String) throws {
        guard let directory = cacheDirectory else { return }
        let fileURL = directory.appendingPathComponent(key)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
