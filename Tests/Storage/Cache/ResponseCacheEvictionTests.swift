//
//  ResponseCacheEvictionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("eviction + grace")
    struct EvictionTests {
        /// Writes an entry with arbitrary storedAt/lastAccessedAt and a body of known size.
        /// Returns the key for later inspection.
        @StorageActor
        private func putEntry(
            itemId: String,
            bodySize: Int,
            storedAt: Date,
            lastAccessedAt: Date
        ) throws -> Cache.ItemKey {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: itemId)
            let body = Data(count: bodySize)
            _ = try Cache.write(body, key: key, dataVersion: 0) { _, _ in true }

            // Rewrite meta directly with the desired storedAt/lastAccessedAt.
            let existing = readMetaFromDisk(for: key)!
            let patched = Cache.Meta(
                key: Cache.ItemKey(
                    profileId: existing.key.profileId,
                    itemType: existing.key.itemType,
                    itemId: existing.key.itemId
                ),
                size: existing.size,
                locale: existing.locale,
                dataVersion: existing.dataVersion,
                storedAt: storedAt,
                lastAccessedAt: lastAccessedAt
            )
            try overwriteMeta(patched, for: key)
            return key
        }

        @Test func eviction_removes_oldest_by_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            // Sized so that exactly one entry must be evicted:
            // total = 50 + 50 + 1 = 101; maxBytes = 60; needToFree = 41;
            // removing k1 (50B, coldest) frees 50 ≥ 41 → done.
            await configureCache(maxBytes: 60, evictionGracePeriod: 3600)

            let oldStored = Date(timeIntervalSinceNow: -7200) // 2h ago → out of grace
            let k1 = try await putEntry(itemId: "o1",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date(timeIntervalSinceNow: -600)) // coldest (10 min ago)
            let k2 = try await putEntry(itemId: "o2",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date(timeIntervalSinceNow: -60))  // warmer (1 min ago)

            // putEntry bypasses enforceCacheSizeLimit; one real write triggers it.
            let triggerKey = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            // Reset upper-bound so eviction does a fresh scan over our hand-crafted metas.
            await resetCacheCounters()
            _ = try await Cache.write(Data(count: 1), key: triggerKey, dataVersion: 0) { _, _ in true }

            // Exact post-state: k1 evicted, k2 + trigger survive.
            let files1 = await filesExist(for: k1)
            let files2 = await filesExist(for: k2)
            let filesT = await filesExist(for: triggerKey)
            #expect(!files1.meta && !files1.body, "coldest entry k1 must be evicted")
            #expect(files2.meta && files2.body, "warmer entry k2 must survive")
            #expect(filesT.meta && filesT.body, "fresh trigger must survive (grace-protected)")

            let entries = await collectAllMeta()
            let total = entries.reduce(0) { $0 + $1.size }
            #expect(total <= 60)
        }

        @Test func eviction_grace_protects_young_records() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 50, evictionGracePeriod: 3600)

            // All entries are fresh (storedAt = now) → grace protects them.
            let now = Date()
            let k1 = try await putEntry(itemId: "o1",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)
            let k2 = try await putEntry(itemId: "o2",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)
            let k3 = try await putEntry(itemId: "o3",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)

            // Trigger eviction.
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger, dataVersion: 0) { _, _ in true }

            // All three should survive despite exceeding the limit.
            for k in [k1, k2, k3] {
                let files = await filesExist(for: k)
                #expect(files.meta && files.body, "Entry \(k.itemId) is grace-protected; should not be evicted")
            }
        }

        @Test func eviction_no_op_when_under_limit() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 1024, evictionGracePeriod: 3600)

            let oldStored = Date(timeIntervalSinceNow: -7200)
            let k = try await putEntry(itemId: "o1",
                                       bodySize: 100,
                                       storedAt: oldStored,
                                       lastAccessedAt: oldStored)

            // Trigger eviction. Total size ~100+1 < 1024 → nothing removed.
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger, dataVersion: 0) { _, _ in true }

            let files = await filesExist(for: k)
            #expect(files.meta && files.body)
        }

        @Test func eviction_sets_cooldown_when_grace_blocks_eviction() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            // 100s grace, all entries fresh → grace blocks every eviction candidate.
            await configureCache(maxBytes: 30, evictionGracePeriod: 100)

            let now = Date()
            _ = try await putEntry(itemId: "o1", bodySize: 40,
                                   storedAt: now, lastAccessedAt: now)
            _ = try await putEntry(itemId: "o2", bodySize: 40,
                                   storedAt: now, lastAccessedAt: now)

            // Trigger a real write so enforceCacheSizeLimit runs.
            await resetCacheCounters()
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger, dataVersion: 0) { _, _ in true }

            // Cooldown must be set, pointing roughly at storedAt + gracePeriod (~now + 100s).
            let cooldown = await Cache.nextEvictionScanAllowedAt
            #expect(cooldown != nil)
            if let cooldown {
                let expected = now.addingTimeInterval(100)
                #expect(abs(cooldown.timeIntervalSince(expected)) < 5)
            }
        }

        @Test func totalBytesUpperBound_never_underestimates_actual_size() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 10_000, evictionGracePeriod: 3600)

            // Three writes; the in-memory upper bound is updated incrementally.
            let k1 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let k2 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "b")
            let k3 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "c")
            _ = try await Cache.write(Data(count: 100), key: k1, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(Data(count: 100), key: k2, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(Data(count: 100), key: k3, dataVersion: 0) { _, _ in true }

            // After three writes the upper bound should equal the actual size.
            let metasAll = await collectAllMeta()
            let actualAll = metasAll.reduce(0) { $0 + $1.size }
            let upperAll = await Cache.totalBytesUpperBound
            #expect(upperAll != nil)
            #expect(upperAll ?? -1 >= actualAll)

            // Bulk-remove via removeCacheItem bypasses the counter delta.
            // The upper bound becomes an overestimate — but never an underestimate.
            await removeCacheItem(for: k2)

            let metasAfter = await collectAllMeta()
            let actualAfter = metasAfter.reduce(0) { $0 + $1.size }
            let upperAfter = await Cache.totalBytesUpperBound
            #expect(upperAfter != nil)
            #expect(upperAfter ?? -1 >= actualAfter, "upper bound must never underestimate actual size")
        }

        @Test func eviction_clears_cooldown_when_freed_under_limit() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 60, evictionGracePeriod: 3600)

            let oldStored = Date(timeIntervalSinceNow: -7200)
            _ = try await putEntry(itemId: "o1", bodySize: 50,
                                   storedAt: oldStored,
                                   lastAccessedAt: Date(timeIntervalSinceNow: -600))

            await resetCacheCounters()
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger, dataVersion: 0) { _, _ in true }

            // Eviction succeeded; no cooldown should be set.
            let cooldown = await Cache.nextEvictionScanAllowedAt
            #expect(cooldown == nil)
        }
    }
}

#endif
