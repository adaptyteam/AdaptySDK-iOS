//
//  Cache+Read.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2026.
//

import Foundation

private let log = Log.cache

@StorageActor
extension Cache {
    @inlinable
    static func read(
        _ key: ItemKey,
        accept: (@Sendable (_ existing: Meta) -> Bool)? = nil
    ) -> Data? {
        let fm = fileManager
        guard let meta = fm.readValidatedCacheMeta(for: key) else {
            return nil
        }

        if let accept {
            guard accept(meta) else { return nil }
        }

        let dataFileURL = key.dataFileURL

        guard let data = try? Data(contentsOf: dataFileURL) else {
            log.warn("Cached data read failed. Self-heal pair. Remove invalid data.")
            fm.removeCacheItem(key: key)
            return nil
        }

        meta.syncLastAccessed()
        return data
    }

    @discardableResult
    @inlinable
    static func touch(
        _ key: ItemKey,
        accept: (@Sendable (_ existing: Meta) -> Bool)? = nil
    ) -> Bool {
        guard let meta = fileManager.readValidatedCacheMeta(for: key) else {
            return false
        }

        if let accept {
            guard accept(meta) else { return false }
        }

        meta.syncLastAccessed()
        return true
    }
}

@StorageActor
extension FileManager {
    func readValidatedCacheMeta(for key: Cache.ItemKey) -> Cache.Meta? {
        let metaFileURL = key.metaFileURL
        let dataFileURL = key.dataFileURL
        guard
            let meta = try? Cache.Meta(from: metaFileURL),
            meta.schemaVersion == key.itemType.schemaVersion,
            meta.key.profileId == key.profileId,
            meta.key.itemType == key.itemType,
            meta.key.itemId == key.itemId,
            fileExists(atPath: dataFileURL.path)
        else {
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
            return nil
        }
        return meta
    }
}
