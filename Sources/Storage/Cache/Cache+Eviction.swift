//
//  Cache+Eviction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2026.
//

import Foundation

@Cache.Actor
extension FileManager {
    /// If `Cache.totalBytesUpperBound` is known and ≤ `maxBytes` — no-op.
    /// If a previous scan left a cooldown (grace blocked everything) and it
    /// hasn't expired — no-op.
    /// Otherwise: full scan over `rootDirectory`, evict by LRU + grace period,
    /// update `Cache.totalBytesUpperBound` with the exact value, and set the
    /// cooldown if grace prevented us from getting under `maxBytes`.
    func enforceCacheSizeLimit() {
        if let current = Cache.totalBytesUpperBound, current <= Cache.maxBytes {
            return
        }
        if let cooldownUntil = Cache.nextEvictionScanAllowedAt, Date() < cooldownUntil {
            return
        }

        guard fileExists(atPath: Cache.rootDirectory.path) else {
            Cache.totalBytesUpperBound = 0
            Cache.nextEvictionScanAllowedAt = nil
            return
        }
        guard let enumerator = enumerator(
            at: Cache.rootDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            Cache.totalBytesUpperBound = 0
            Cache.nextEvictionScanAllowedAt = nil
            return
        }

        var totalSize = 0
        var items: [Cache.Meta] = []
        for case let url as URL in enumerator where url.pathExtension == Cache.metaFileExtension {
            guard
                let meta = try? Cache.Meta(from: url)
            else {
                let dataFileURL = url.deletingPathExtension().appendingPathExtension(Cache.dataFileExtension)
                removeCacheItem(metaFileURL: url, dataFileURL: dataFileURL)
                continue
            }
            totalSize += meta.size
            items.append(meta)
        }

        guard totalSize > Cache.maxBytes else {
            Cache.totalBytesUpperBound = totalSize
            Cache.nextEvictionScanAllowedAt = nil
            return
        }

        let now = Date()
        let candidates = items
            .filter { now.timeIntervalSince($0.storedAt) >= Cache.evictionGracePeriod }
            .sorted { $0.lastAccessedAt < $1.lastAccessedAt }

        let needToFree = totalSize - Cache.maxBytes
        var freed = 0
        for item in candidates {
            if freed >= needToFree { break }
            // delete-meta-first
            removeCacheItem(key: item.key)
            freed += item.size
        }
        Cache.totalBytesUpperBound = totalSize - freed

        if freed >= needToFree {
            Cache.nextEvictionScanAllowedAt = nil
        } else {
            // Grace blocked further eviction. Postpone the next scan until the
            // earliest currently-grace-protected item could exit grace.
            Cache.nextEvictionScanAllowedAt = items
                .filter { now.timeIntervalSince($0.storedAt) < Cache.evictionGracePeriod }
                .map { $0.storedAt.addingTimeInterval(Cache.evictionGracePeriod) }
                .min()
        }
    }
}
