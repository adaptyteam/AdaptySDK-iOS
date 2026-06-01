//
//  ResponseCacheBasicTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("basic write/read/touch/writeOrRead")
    struct BasicTests {
        private let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
        private let payload = TestPayload(id: "a", value: 1)
        private let altPayload = TestPayload(id: "b", value: 2)

        // MARK: - write

        @Test func write_to_empty_cache_returns_true_and_stores() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let written = try await Cache.write(
                payload.encoded(),
                key: key,
                locale: "en",
                dataVersion: 7
            ) { _, _ in true }

            #expect(written)

            // Via accept, verify that meta saved the passed fields.
            let captured = Box<Cache.Meta?>(nil)
            let value: TestPayload? = await Cache.read(
                key,
                accept: { meta in
                    captured.value = meta
                    return true
                },
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
            #expect(captured.value?.locale == "en")
            #expect(captured.value?.dataVersion == 7)
            #expect(try captured.value?.size == (payload.encoded()).count)
        }

        @Test func write_with_accept_false_keeps_cache_returns_false() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let originalMeta = await readMetaFromDisk(for: key)
            #expect(originalMeta != nil)

            let written = try await Cache.write(
                altPayload.encoded(),
                key: key,
                dataVersion: 0
            ) { _, _ in false } // accept=false → don't overwrite

            #expect(!written)

            // Contents are unchanged.
            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
        }

        @Test func write_with_accept_true_overwrites_returns_true() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let written = try await Cache.write(
                altPayload.encoded(),
                key: key,
                dataVersion: 0
            ) { _, _ in true }

            #expect(written)

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == altPayload)
        }

        @Test func two_writes_keep_only_one_pair_on_disk() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(altPayload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let dir = await key.directory
            let contents = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            let metas = contents.filter { $0.hasSuffix(".meta") }
            let bodies = contents.filter { $0.hasSuffix(".data") }
            #expect(metas.count == 1)
            #expect(bodies.count == 1)

            // body contains the fresh data.
            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == altPayload)
        }

        // MARK: - read<T>

        @Test func read_with_accept_true_returns_decoded() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
        }

        @Test func read_with_accept_false_returns_nil_and_keeps_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let originalLastAccessed = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(originalLastAccessed != nil)

            // sleep 1ms so Date() is guaranteed to differ
            try await Task.sleep(nanoseconds: 10_000_000)

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in false },
                decode: TestPayload.decode(_:)
            )
            #expect(value == nil)

            let afterLastAccessed = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(afterLastAccessed == originalLastAccessed)
        }

        @Test func read_returns_nil_when_no_entry() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == nil)
        }

        @Test func read_decoder_throws_returns_nil_and_removes_pair() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: { _ in throw TestDecodeError() }
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func read_updates_lastAccessedAt_on_success() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000) // 10ms

            _ = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(before != nil && after != nil)
            if let before, let after {
                #expect(after > before)
            }
        }

        // MARK: - touch

        @Test func touch_accept_true_updates_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000)

            let touched = await Cache.touch(key) { _ in true }
            #expect(touched)

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            if let before, let after {
                #expect(after > before)
            }
        }

        @Test func touch_accept_false_returns_false_and_keeps_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000)

            let touched = await Cache.touch(key) { _ in false }
            #expect(!touched)

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            #expect(before == after)
        }

        @Test func touch_returns_false_when_no_entry() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let touched = await Cache.touch(key) { _ in true }
            #expect(!touched)
        }

        // MARK: - writeOrRead

        @Test func writeOrRead_empty_cache_writes_and_returns_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let result = try await Cache.writeOrRead(
                payload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(result == payload)

            // The entry was stored in the cache.
            let cached: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == payload)
        }

        @Test func writeOrRead_accept_false_returns_cached_does_not_write_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let result = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in false }, // don't use new → read cached
                decode: TestPayload.decode(_:)
            )
            #expect(result == payload) // returned cached, not altPayload

            // Old body is still on disk.
            let cached: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == payload)
        }

        @Test func writeOrRead_accept_false_updates_lastAccessedAt_of_cached() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: key)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000)

            _ = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in false },
                decode: TestPayload.decode(_:)
            )

            let after = await readMetaFromDisk(for: key)?.lastAccessedAt
            if let before, let after {
                #expect(after > before)
            }
        }

        @Test func writeOrRead_accept_true_writes_new_returns_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let result = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in true }, // use new
                decode: TestPayload.decode(_:)
            )
            #expect(result == altPayload)

            let cached: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == altPayload)
        }

        @Test func writeOrRead_new_decode_fails_with_empty_cache_throws() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await #expect(throws: TestDecodeError.self) {
                let _: TestPayload = try await Cache.writeOrRead(
                    Data([0xFF, 0xFE]),
                    key: key,
                    dataVersion: 0,
                    accept: { _, _ in true },
                    decode: { (_: Data) throws -> TestPayload in throw TestDecodeError() }
                )
            }

            // Nothing landed in the cache.
            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func writeOrRead_new_decode_fails_with_valid_cache_falls_back_to_cached() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // New data fails to decode, but a valid entry exists in cache
            // (accept=true → "use new", but new is broken → fallback to cached).
            let result = try await Cache.writeOrRead(
                Data([0xFF, 0xFE]),
                key: key,
                dataVersion: 0,
                accept: { _, _ in true },
                decode: { data -> TestPayload in
                    // Throw only on 0xFF-bytes; valid JSON decodes normally.
                    if data == Data([0xFF, 0xFE]) { throw TestDecodeError() }
                    return try TestPayload.decode(data)
                }
            )
            #expect(result == payload) // fallback to cached

            // Cache was not overwritten.
            let cached: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == payload)
        }

        @Test func writeOrRead_cached_body_broken_falls_back_to_new() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            // Replace body with garbage. accept=false (we want cached), but it's broken.
            try await writeRawBody(Data([0xAB, 0xCD]), for: key)

            let result = try await Cache.writeOrRead(
                altPayload.encoded(),
                key: key,
                dataVersion: 0,
                accept: { _, _ in false }, // we want cached
                decode: TestPayload.decode(_:) // but cached decode will fail — fallback to new
            )
            #expect(result == altPayload)

            // Cache replaced with the new entry.
            let cached: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == altPayload)
        }

        @Test func writeOrRead_cached_broken_and_new_also_fails_throws_new_error() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            try await writeRawBody(Data([0xAB, 0xCD]), for: key)

            await #expect(throws: TestDecodeError.self) {
                let _: TestPayload = try await Cache.writeOrRead(
                    Data([0xFF, 0xFE]),
                    key: key,
                    dataVersion: 0,
                    accept: { _, _ in false },
                    decode: { _ throws -> TestPayload in throw TestDecodeError() }
                )
            }

            // Pair removed by self-heal.
            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }
    }
}

#endif
