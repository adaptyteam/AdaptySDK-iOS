//
//  Cache+Remove.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.05.2026.
//

import Foundation

@Cache.Actor
extension Cache {
    @inlinable
    static func removeAll() {
        try? fileManager.removeItem(at: rootDirectory)
        totalBytesUpperBound = 0
        nextEvictionScanAllowedAt = nil
    }

    @inlinable
    static func removeProfile(_ profileId: String) {
        let dir = directory(forProfileId: profileId)
        try? fileManager.removeItem(at: dir)
    }

    @inlinable
    static func removeItemType(profileId: String, itemType: ItemType) {
        let dir = directory(forProfileId: profileId, itemType: itemType)
        try? fileManager.removeItem(at: dir)
    }
}

@Cache.Actor
extension FileManager {
    func removeCacheItem(key: Cache.ItemKey) {
        removeCacheItem(
            metaFileURL: key.metaFileURL,
            dataFileURL: key.dataFileURL
        )
    }

    func removeCacheItem(metaFileURL: URL, dataFileURL: URL) {
        try? removeItem(at: metaFileURL)
        try? removeItem(at: dataFileURL)
    }
}
