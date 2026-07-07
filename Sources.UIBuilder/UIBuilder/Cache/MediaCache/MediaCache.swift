import Foundation

enum MediaCache {
    @MainActor
    static let cache = ImageCache(name: "Adapty")

    @MainActor
    static let downloader = ImageDownloader(name: "Adapty")

    @MainActor
    private static var _currentConfiguration: MediaCacheConfiguration?

    @MainActor
    static var currentConfiguration: MediaCacheConfiguration? {
        _currentConfiguration
    }

    @MainActor
    static func configure(_ configuration: MediaCacheConfiguration) {
        cache.memoryStorage.config.totalCostLimit = configuration.memoryStorageTotalCostLimit
        cache.memoryStorage.config.countLimit = configuration.memoryStorageCountLimit
        cache.diskStorage.config.sizeLimit = configuration.diskStorageSizeLimit
        cache.memoryStorage.config.expiration = .never
        cache.diskStorage.config.expiration = .never
        _currentConfiguration = configuration
    }

    @MainActor
    static func clear() async {
        cache.clearMemoryCache()
        await cache.clearDiskCache()
    }
}
