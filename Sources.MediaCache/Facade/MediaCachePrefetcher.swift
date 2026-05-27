import Foundation

@MainActor
package final class MediaCachePrefetcher {
    package init() {}

    package func prefetch(
        urls: Set<URL>,
        completion: (@Sendable (_ skipped: Int, _ failed: Int, _ completed: Int) -> Void)? = nil
    ) {
        let prefetcher = ImagePrefetcher(
            sources: urls.map { .network($0) },
            options: [
                .targetCache(MediaCache.cache),
                .downloader(MediaCache.downloader),
            ],
            completionHandler: { skipped, failed, completed in
                completion?(skipped.count, failed.count, completed.count)
            }
        )
        prefetcher.start()
    }
}
