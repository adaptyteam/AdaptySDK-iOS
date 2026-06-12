//
//  ResponseCacheDataOverloadTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 21.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("Data overloads (read/writeOrRead without decode)")
    struct DataOverloadTests {
        private let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
        private let payload = TestPayload(id: "a", value: 1)
        private let altPayload = TestPayload(id: "b", value: 2)

        // MARK: - read(_:accept:) -> Data?

        @Test func read_data_returns_raw_bytes_on_hit() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let encoded = try payload.encoded()
            _ = try await Cache.write(encoded, key: key, dataVersion: 0) { _, _ in true }

            let data: Data? = await Cache.read(key)
            #expect(data == encoded)
        }

        @Test func read_data_passes_meta_into_accept() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(
                payload.encoded(),
                key: key,
                locale: "en",
                dataVersion: 7
            ) { _, _ in true }

            let captured = Box<Cache.Meta?>(nil)
            let data: Data? = await Cache.read(key, accept: { meta in
                captured.value = meta
                return true
            })

            #expect(data != nil)
            #expect(captured.value?.locale == "en")
            #expect(captured.value?.dataVersion == 7)
            #expect(captured.value?.key.itemId == "obj1")
        }

        @Test func read_data_accept_false_returns_nil_and_keeps_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(before != nil)

            try await Task.sleep(nanoseconds: 10_000_000)

            let data: Data? = await Cache.read(key, accept: { _ in false })
            #expect(data == nil)

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(after == before)
        }

        @Test func read_data_returns_nil_when_no_entry() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let data: Data? = await Cache.read(key)
            #expect(data == nil)
        }

        @Test func read_data_updates_lastAccessedAt_on_success() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000)

            _ = await Cache.read(key)

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(before != nil && after != nil)
            if let before, let after {
                #expect(after > before)
            }
        }

        @Test func read_data_missing_body_self_heals_returns_nil() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeBodyOnly(for: key)

            let data: Data? = await Cache.read(key)
            #expect(data == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func read_data_corrupt_meta_self_heals_returns_nil() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            try await writeRawMeta(Data("garbage".utf8), for: key)

            let data: Data? = await Cache.read(key)
            #expect(data == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func read_data_returns_arbitrary_bytes_unchanged() async throws {
            // Cache must not interpret/transform bytes — round-trip exactly.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let raw = Data((0 ... 255).map { UInt8($0) })
            _ = try await Cache.write(raw, key: key, dataVersion: 0) { _, _ in true }

            let read: Data? = await Cache.read(key)
            #expect(read == raw)
        }

        // MARK: - writeOrRead(...) -> Data

        @Test func writeOrRead_data_empty_cache_writes_and_returns_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let newData = try payload.encoded()
            let returned = try await Cache.writeOrRead(
                newData,
                key: key,
                dataVersion: 0
            )
            #expect(returned == newData)

            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == newData)
        }

        @Test func writeOrRead_data_accept_true_overwrites_returns_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let newData = try altPayload.encoded()
            let returned = try await Cache.writeOrRead(
                newData,
                key: key,
                dataVersion: 0,
                accept: { _, _ in true }
            )
            #expect(returned == newData)

            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == newData)
        }

        @Test func writeOrRead_data_accept_false_returns_cached_bytes() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let cachedEncoded = try payload.encoded()
            _ = try await Cache.write(cachedEncoded, key: key, dataVersion: 0) { _, _ in true }

            let newData = try altPayload.encoded()
            let returned = try await Cache.writeOrRead(
                newData,
                key: key,
                dataVersion: 0,
                accept: { _, _ in false } // refuse new, return cached
            )
            #expect(returned == cachedEncoded)

            // Disk still holds the original bytes — newData was not written.
            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == cachedEncoded)
        }

        @Test func writeOrRead_data_accept_false_updates_lastAccessedAt_of_cached() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000)

            _ = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in false }
            )

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            if let before, let after {
                #expect(after > before)
            }
        }

        @Test func writeOrRead_data_accept_false_cached_body_missing_falls_back_to_new() async throws {
            // Cached meta exists but body file vanished (crash between writes).
            // accept=false says "prefer cached", but cached is broken → fall back to new.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeBodyOnly(for: key)

            let newData = try altPayload.encoded()
            let returned = try await Cache.writeOrRead(
                newData,
                key: key,
                dataVersion: 0,
                accept: { _, _ in false }
            )
            #expect(returned == newData)

            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == newData)
        }

        @Test func writeOrRead_data_passes_both_meta_into_accept() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 3) { _, _ in true }

            let capturedNew = Box<Cache.Meta?>(nil)
            let capturedExisting = Box<Cache.Meta?>(nil)
            _ = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 5,
                accept: { new, existing in
                    capturedNew.value = new
                    capturedExisting.value = existing
                    return true
                }
            )

            #expect(capturedNew.value?.dataVersion == 5)
            #expect(capturedExisting.value?.dataVersion == 3)
        }

        @Test func writeOrRead_data_corrupt_meta_writes_new() async throws {
            // Corrupt meta → readValidatedCacheMeta returns nil → treated as
            // empty cache: writes new and returns new.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            try await writeRawMeta(Data("garbage".utf8), for: key)

            let newData = try altPayload.encoded()
            let returned = try await Cache.writeOrRead(
                newData,
                key: key,
                dataVersion: 0,
                accept: { _, _ in false } // would have preferred cached, but cached is gone
            )
            #expect(returned == newData)

            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == newData)
        }

        @Test func writeOrRead_data_returns_arbitrary_bytes_unchanged() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let raw = Data((0 ... 255).map { UInt8($0) })
            let returned = try await Cache.writeOrRead(
                raw,
                key: key,
                dataVersion: 0
            )
            #expect(returned == raw)

            let onDisk: Data? = await Cache.read(key)
            #expect(onDisk == raw)
        }

        // MARK: - interaction with generic overload

        @Test func data_and_generic_read_observe_same_bytes() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let encoded = try payload.encoded()
            _ = try await Cache.write(encoded, key: key, dataVersion: 0) { _, _ in true }

            let dataView: Data? = await Cache.read(key)
            let decodedView: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:)
            )

            #expect(dataView == encoded)
            #expect(decodedView == payload)
        }
    }
}

#endif

