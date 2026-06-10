//
//  Cache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.05.2026.
//

import Foundation

@StorageActor
enum Cache {
    static var maxBytes: Int = 20 * 1024 * 1024
    /// How long a freshly-written entry is protected from LRU eviction,
    /// counted from `storedAt`. 15 min covers a typical user session plus
    /// a short return from background, while keeping `maxBytes` a meaningful
    /// soft cap on bursty writes. Lower this if `maxBytes` shrinks or if the
    /// cache starts storing heavy payloads (media, large blobs).
    static var evictionGracePeriod: TimeInterval = 15 * 60

    /// Upper-bound estimate of the total data-file size under `rootDirectory`.
    /// **Never underestimates** — actual size is always ≤ this value.
    /// `nil` → not computed yet (cold start / reset in tests).
    /// Maintained via deltas on write. Bulk-remove operations (`removeOtherProfiles`/
    /// `cleanup`) intentionally do **not** update it — an extra overestimate
    /// is safe, since `enforceCacheSizeLimit()` will recompute the exact value
    /// on the next overflow. `removeAll` resets it to 0 directly.
    static var totalBytesUpperBound: Int?

    /// Cooldown: when set, `enforceCacheSizeLimit()` skips the full scan until
    /// this moment. Used after a scan in which grace-protected items kept the
    /// cache over `maxBytes` — re-scanning before any grace expires would be
    /// pointless and costly on every write. The value is the earliest moment
    /// some currently-grace-protected item could become evictable.
    static var nextEvictionScanAllowedAt: Date?

    /// Private `FileManager` instance — isolates us from any `delegate` that
    /// foreign code may install on `FileManager.default`.
    static let fileManager = FileManager()
}

