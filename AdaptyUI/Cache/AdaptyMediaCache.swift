//
//  AdaptyMediaCache.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyUI {
    static let imageCache = ImageCache(name: "Adapty")
    static let imageDownloader = ImageDownloader(name: "Adapty")

    public struct MediaCacheConfiguration {
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
    }

    static var currentCacheConfiguration: MediaCacheConfiguration?

    static func configureMediaCache(_ configuration: MediaCacheConfiguration) {
        Log.verbose("""
            [UI] #AdaptyMediaCache# configure: memoryStorageTotalCostLimit = \(configuration.memoryStorageTotalCostLimit), memoryStorageCountLimit = \(configuration.memoryStorageCountLimit), diskStorageSizeLimit = \(configuration.diskStorageSizeLimit)
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
    ///                      This `handler` will be called from the main queue.
    public static func clearMediaCache(completion: (() -> Void)? = nil) {
        Log.verbose("[UI] #AdaptyMediaCache# clearMediaCache")

        imageCache.clearMemoryCache()
        imageCache.clearDiskCache(completion: completion)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI {
    class ImageUrlPrefetcher: AdaptyUIImageUrlObserver {
        static let queue = DispatchQueue(label: "AdaptyUI.SDK.ImageUrlPrefetcher")
        static let shared = ImageUrlPrefetcher()

        private var initialized = false

        func initialize() {
            defer { initialized = true }
            guard !initialized else { return }

            Log.verbose("[UI] #ImageUrlPrefetcher# initialize")
            AdaptyUI.setImageUrlObserver(self, dispatchQueue: Self.queue)
        }

        func extractedImageUrls(_ urls: Set<URL>) {
            let logId = Log.stamp

            Log.verbose("[UI] #ImageUrlPrefetcher# cacheImagesIfNeeded: \(urls) [\(logId)]")

            let prefetcher = ImagePrefetcher(
                sources: urls.map { .network($0) },
                options: [
                    .targetCache(imageCache),
                    .downloader(imageDownloader),
                ],
                completionHandler: { skipped, failed, completed in
                    Log.verbose("[UI] #ImageUrlPrefetcher# cacheImagesIfNeeded: skipped = \(skipped), failed = \(failed), completed = \(completed) [\(logId)]")
                }
            )

            prefetcher.start()
        }
    }
}
