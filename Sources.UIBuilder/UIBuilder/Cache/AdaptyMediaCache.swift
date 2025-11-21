//
//  AdaptyUIMediaCache.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

public extension AdaptyUIBuilder {
    struct MediaCacheConfiguration: Sendable {
        /// Total cost limit of the storage in bytes.
        public var memoryStorageTotalCostLimit: Int

        /// The item count limit of the memory storage.
        public var memoryStorageCountLimit: Int

        /// The file size limit on disk of the storage in bytes. 0 means no limit.
        public var diskStorageSizeLimit: UInt

        public init(
            memoryStorageTotalCostLimit: Int,
            memoryStorageCountLimit: Int,
            diskStorageSizeLimit: UInt
        ) {
            self.memoryStorageTotalCostLimit = memoryStorageTotalCostLimit
            self.memoryStorageCountLimit = memoryStorageCountLimit
            self.diskStorageSizeLimit = diskStorageSizeLimit
        }

        package static let `default`: MediaCacheConfiguration = .init(
            memoryStorageTotalCostLimit: 100 * 1024 * 1024, // 100MB
            memoryStorageCountLimit: .max,
            diskStorageSizeLimit: 100 * 1024 * 1024 // 100MB
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension AdaptyUIBuilder {
    static let imageCache = ImageCache(name: "Adapty")
    static let imageDownloader = ImageDownloader(name: "Adapty")

    static var currentCacheConfiguration: MediaCacheConfiguration?

    package static func configureMediaCache(_ configuration: MediaCacheConfiguration) {
        Log.cache.verbose("""
        configure: memoryStorageTotalCostLimit = \(configuration.memoryStorageTotalCostLimit), memoryStorageCountLimit = \(configuration.memoryStorageCountLimit), diskStorageSizeLimit = \(configuration.diskStorageSizeLimit)
        """)

        imageCache.memoryStorage.config.totalCostLimit = configuration.memoryStorageTotalCostLimit
        imageCache.memoryStorage.config.countLimit = configuration.memoryStorageCountLimit
        imageCache.diskStorage.config.sizeLimit = configuration.diskStorageSizeLimit

        imageCache.memoryStorage.config.expiration = .never
        imageCache.diskStorage.config.expiration = .never

        currentCacheConfiguration = configuration
    }

    /// Clears the memory storage and the disk storage of this cache. This is an async operation.
    /// - Parameter completion: A closure which is invoked when the cache clearing operation finishes.
    public static func clearMediaCache() async {
        Log.cache.verbose("clearMediaCache")

        imageCache.clearMemoryCache()
        await imageCache.clearDiskCache()
    }

    /// Clears the memory storage and the disk storage of this cache. This is an async operation.
    /// - Parameter completion: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    public static func clearMediaCache(completion: (() -> Void)? = nil) {
        Task { @MainActor in
            await clearMediaCache()
            completion?()
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUIBuilder {
    @MainActor
    final class ImageUrlPrefetcher: AdaptyUIImageUrlObserver {
        package static let shared = ImageUrlPrefetcher()

        private var initialized = false

        package func initialize() {
            defer { initialized = true }
            guard !initialized else { return }

            Log.prefetcher.verbose("initialize")
            AdaptyUIBuilder.setImageUrlObserver(self)
        }

        package nonisolated func extractedImageUrls(_ urls: Set<URL>) {
            Task { @MainActor in
                let logId = Log.stamp

                Log.prefetcher.verbose("cacheImagesIfNeeded: \(urls) [\(logId)]")

                let prefetcher = ImagePrefetcher(
                    sources: urls.map { .network($0) },
                    options: [
                        .targetCache(imageCache),
                        .downloader(imageDownloader),
                    ],
                    completionHandler: { skipped, failed, completed in
                        Log.prefetcher.verbose("cacheImagesIfNeeded: skipped = \(skipped), failed = \(failed), completed = \(completed) [\(logId)]")
                    }
                )

                prefetcher.start()
            }
        }
    }
}
