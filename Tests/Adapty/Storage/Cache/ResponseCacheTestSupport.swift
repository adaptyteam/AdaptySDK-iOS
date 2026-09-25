//
//  ResponseCacheTestSupport.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation

extension StorageCacheTests {
    /// Creates a unique tmp-root and overrides `Cache.rootDirectory`. Returns the
    /// root URL where this test's cache lives. Tests are responsible for cleanup
    /// via `cleanupCacheTest(_:)` (typically through `defer`).
    @StorageActor
    static func prepareCacheTest(testName: String = #function) -> URL {
        let safeName = testName
            .replacingOccurrences(of: "(", with: "_")
            .replacingOccurrences(of: ")", with: "_")
            .replacingOccurrences(of: " ", with: "_")
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("AdaptyTests-Cache", isDirectory: true)
            .appendingPathComponent("\(safeName)-\(UUID().uuidString)", isDirectory: true)
        Cache.rootDirectory = root
        Cache.totalBytesUpperBound = nil
        Cache.nextEvictionScanAllowedAt = nil
        return root
    }

    /// Removes the tmp directory. Called from the test after `prepareCacheTest`.
    static func cleanupCacheTest(_ root: URL) {
        try? FileManager.default.removeItem(at: root)
    }

    /// Sets the limits used by eviction tests.
    @StorageActor
    static func configureCache(maxBytes: Int, evictionGracePeriod: TimeInterval) {
        Cache.maxBytes = maxBytes
        Cache.evictionGracePeriod = evictionGracePeriod
    }

    /// Forces `enforceCacheSizeLimit` to do a full disk scan on the next write
    /// (otherwise the in-memory counter may short-circuit eviction).
    @StorageActor
    static func resetCacheCounters() {
        Cache.totalBytesUpperBound = nil
        Cache.nextEvictionScanAllowedAt = nil
    }

    /// Test payload for encode/decode checks.
    struct TestPayload: Codable, Equatable, Sendable {
        let id: String
        let value: Int

        func encoded() throws -> Data {
            try JSONEncoder().encode(self)
        }

        static func decode(_ data: Data) throws -> TestPayload {
            try JSONDecoder().decode(TestPayload.self, from: data)
        }

        /// `decode` for `Cache.read` / `Cache.writeOrRead` — `meta` corresponds to `data`; ignored here.
        static func decode(_: Cache.Meta, _ data: Data) throws -> TestPayload {
            try decode(data)
        }
    }

    /// Marker error for decoders, to distinguish "intentional failure from our code" from any other.
    struct TestDecodeError: Error {}

    /// Convenience for tests: build an `AdaptyUserId` from a profileId.
    static func userId(_ profileId: String) -> AdaptyUserId {
        AdaptyUserId(profileId: profileId, customerId: nil)
    }

    /// Thread-unsafe (but safe inside `@StorageActor`) container for side-effect
    /// capture from accept-closures.
    final class Box<T>: @unchecked Sendable {
        var value: T
        init(_ value: T) {
            self.value = value
        }
    }

    /// Reads `.meta` directly (to inspect stored fields in tests).
    @StorageActor
    static func readMetaFromDisk(for key: Cache.ItemKey) -> Cache.Meta? {
        try? Cache.Meta(from: key.metaFileURL)
    }

    /// Reads `.data` directly.
    @StorageActor
    static func readBodyFromDisk(for key: Cache.ItemKey) -> Data? {
        try? Data(contentsOf: key.dataFileURL)
    }

    /// Checks the existence of the pair (meta + data) on disk.
    @StorageActor
    static func filesExist(for key: Cache.ItemKey) -> (meta: Bool, body: Bool) {
        let fm = FileManager.default
        return (
            meta: fm.fileExists(atPath: key.metaFileURL.path),
            body: fm.fileExists(atPath: key.dataFileURL.path)
        )
    }

    /// Overwrites the `.meta` file with arbitrary bytes (to simulate corrupted meta).
    @StorageActor
    static func writeRawMeta(_ data: Data, for key: Cache.ItemKey) throws {
        try FileManager.default.createDirectory(
            at: key.directory,
            withIntermediateDirectories: true
        )
        try data.write(to: key.metaFileURL, options: [.atomic])
    }

    /// Overwrites the `.data` file with arbitrary bytes (to simulate corrupted body).
    @StorageActor
    static func writeRawBody(_ data: Data, for key: Cache.ItemKey) throws {
        try FileManager.default.createDirectory(
            at: key.directory,
            withIntermediateDirectories: true
        )
        try data.write(to: key.dataFileURL, options: [.atomic])
    }

    /// Removes the body file, keeping the meta (simulates a crash / external tampering).
    @StorageActor
    static func removeBodyOnly(for key: Cache.ItemKey) {
        try? FileManager.default.removeItem(at: key.dataFileURL)
    }

    /// Removes the meta file, keeping the body (simulates a crash between write steps).
    @StorageActor
    static func removeMetaOnly(for key: Cache.ItemKey) {
        try? FileManager.default.removeItem(at: key.metaFileURL)
    }

    /// Writes a `Cache.Meta` directly (used to override `lastAccessedAt`/`storedAt`
    /// in eviction tests).
    @StorageActor
    static func overwriteMeta(_ meta: Cache.Meta, for key: Cache.ItemKey) throws {
        let data = try JSONEncoder().encode(meta)
        try writeRawMeta(data, for: key)
    }

    /// Overwrites the `schemaVersion` field in an existing `.meta` (used to test
    /// schema mismatch — the public API does not allow changing schemaVersion directly).
    @StorageActor
    static func overwriteMetaSchemaVersion(_ schemaVersion: Int, for key: Cache.ItemKey) throws {
        let original = try Data(contentsOf: key.metaFileURL)
        guard
            var dict = try JSONSerialization.jsonObject(with: original) as? [String: Any]
        else {
            throw TestDecodeError()
        }
        dict["format"] = schemaVersion
        let patched = try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
        try writeRawMeta(patched, for: key)
    }

    /// Removes the (meta + data) pair for the given key.
    @StorageActor
    static func removeCacheItem(for key: Cache.ItemKey) {
        FileManager.default.removeCacheItem(key: key)
    }

    /// Collects all valid `Meta` under `Cache.rootDirectory` (replacement for a deprecated API).
    @StorageActor
    static func collectAllMeta() -> [Cache.Meta] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: Cache.rootDirectory.path) else { return [] }
        guard let enumerator = fm.enumerator(
            at: Cache.rootDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var result: [Cache.Meta] = []
        for case let url as URL in enumerator where url.pathExtension == Cache.metaFileExtension {
            if let meta = try? Cache.Meta(from: url) {
                result.append(meta)
            }
        }
        return result
    }
}

#endif
