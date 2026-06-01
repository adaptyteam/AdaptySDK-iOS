//
//  Cache+Write.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2026.
//

import Foundation

private let log = Log.cache

@Cache.Actor
extension Cache {
    @discardableResult
    @inlinable
    static func write(
        _ data: Data,
        key: ItemKey,
        locale: String? = nil,
        dataVersion: Int,
        accept: @Sendable (_ new: Meta, _ existing: Meta) -> Bool
    ) throws -> Bool {
        let now = Date()

        let newMeta = Cache.Meta(
            key: key,
            size: data.count,
            locale: locale,
            dataVersion: dataVersion,
            storedAt: now,
            lastAccessedAt: now
        )

        let fm = fileManager
        let existing = fm.readValidatedCacheMeta(for: key)
        if let existing, !accept(newMeta, existing) {
            return false
        }

        try fm.writeCacheItem(
            data: data,
            meta: newMeta,
            oldDataSize: existing?.size ?? 0
        )
        return true
    }
}

@Cache.Actor
extension FileManager {
    func writeCacheItem(
        data: Data,
        meta: Cache.Meta,
        oldDataSize: Int
    ) throws {
        let dir = meta.key.directory
        try ensureDirectoryExists(dir)

        // best-effort first delete old meta file
        try? removeItem(at: meta.key.metaFileURL)

        try data.write(
            to: meta.key.dataFileURL,
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )

        try meta.write()

        // Maintain counter by delta.
        if let current = Cache.totalBytesUpperBound {
            Cache.totalBytesUpperBound = current + data.count - oldDataSize
        }

        enforceCacheSizeLimit()
    }

    private func ensureDirectoryExists(_ url: URL) throws {
        if !fileExists(atPath: Cache.rootDirectory.path) {
            try createDirectory(at: Cache.rootDirectory, withIntermediateDirectories: true)
            applyAttributes()
        }
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    private func applyAttributes() {
        var url = Cache.rootDirectory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
            try url.setResourceValues(values)
        } catch {
            log.warn("Cannot set isExcludedFromBackup attribute at \(url.path): \(error)")
        }
    }
}
