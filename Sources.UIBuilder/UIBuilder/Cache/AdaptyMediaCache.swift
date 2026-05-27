//
//  AdaptyUIMediaCache.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import AdaptyMediaCache
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

@MainActor
extension AdaptyUIBuilder {
    package static func configureMediaCache(_ configuration: MediaCacheConfiguration) {
        Log.cache.verbose("""
        configure: memoryStorageTotalCostLimit = \(configuration.memoryStorageTotalCostLimit), memoryStorageCountLimit = \(configuration.memoryStorageCountLimit), diskStorageSizeLimit = \(configuration.diskStorageSizeLimit)
        """)

        MediaCache.configure(.init(
            memoryStorageTotalCostLimit: configuration.memoryStorageTotalCostLimit,
            memoryStorageCountLimit: configuration.memoryStorageCountLimit,
            diskStorageSizeLimit: configuration.diskStorageSizeLimit
        ))
    }

    /// Clears the memory storage and the disk storage of this cache. This is an async operation.
    public static func clearMediaCache() async {
        Log.cache.verbose("clearMediaCache")
        await MediaCache.clear()
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

package extension AdaptyUIBuilder {
    @MainActor
    final class ImageUrlPrefetcher: AdaptyUIImageUrlObserver {
        package static let shared = ImageUrlPrefetcher()

        private let prefetcher = MediaCachePrefetcher()
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

                prefetcher.prefetch(urls: urls) { skipped, failed, completed in
                    Log.prefetcher.verbose("cacheImagesIfNeeded: skipped = \(skipped), failed = \(failed), completed = \(completed) [\(logId)]")
                }
            }
        }
    }
}
