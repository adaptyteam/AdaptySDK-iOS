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
        AdaptyUI.writeLog(
            level: .verbose,
            message: """
            #AdaptyMediaCache# configure: memoryStorageTotalCostLimit = \(configuration.memoryStorageTotalCostLimit), memoryStorageCountLimit = \(configuration.memoryStorageCountLimit), diskStorageSizeLimit = \(configuration.diskStorageSizeLimit)
            """
        )

        imageCache.memoryStorage.config.totalCostLimit = configuration.memoryStorageTotalCostLimit
        imageCache.memoryStorage.config.countLimit = configuration.memoryStorageCountLimit
        imageCache.diskStorage.config.sizeLimit = configuration.diskStorageSizeLimit

        imageCache.memoryStorage.config.expiration = .never
        imageCache.diskStorage.config.expiration = .never

        currentCacheConfiguration = configuration
    }

    public static func clearMediaCache() {
        AdaptyUI.writeLog(level: .verbose, message: "#AdaptyMediaCache# clearMediaCache")

        imageCache.clearMemoryCache()
        imageCache.clearDiskCache()
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

            AdaptyUI.writeLog(level: .verbose, message: "#ImageUrlPrefetcher# initialize")
            AdaptyUI.setImageUrlObserver(self, dispatchQueue: Self.queue)
        }

        func extractedImageUrls(_ urls: Set<URL>) {
            let logId = AdaptyUI.generateLogId()

            AdaptyUI.writeLog(level: .verbose, message: "#ImageUrlPrefetcher# chacheImagesIfNeeded: \(urls) [\(logId)]")

            let prefetcher = ImagePrefetcher(
                sources: urls.map { .network($0) },
                options: [
                    .targetCache(imageCache),
                    .downloader(imageDownloader),
                ],
                completionHandler: { skipped, failed, completed in
                    AdaptyUI.writeLog(level: .verbose, message: "#ImageUrlPrefetcher# chacheImagesIfNeeded: skipped = \(skipped), failed = \(failed), completed = \(completed) [\(logId)]")
                }
            )

            prefetcher.start()
        }
    }
}
