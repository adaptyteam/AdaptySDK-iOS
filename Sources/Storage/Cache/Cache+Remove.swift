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
    static func removeOtherProfiles(_ profileId: String) {
        let fm = fileManager
        let rootDirectoryPath = rootDirectory.path
        guard
            fm.fileExists(atPath: rootDirectoryPath),
            let subdirectories = try? fm.contentsOfDirectory(atPath: rootDirectoryPath),
            !subdirectories.isEmpty
        else { return }

        let currentProfileDirectoryName = directoryName(forProfileId: profileId)
        for name in subdirectories
            where name != currentProfileDirectoryName && name != sharedDirectoryName {
            try? fm.removeItem(at: rootDirectory.appendingPathComponent(name, isDirectory: true))
        }
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
