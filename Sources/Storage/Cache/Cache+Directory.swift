//
//  Cache+Directory.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.05.2026.
//

import Foundation

@Cache.Actor
extension Cache {
    static let metaFileExtension = "meta"
    static let dataFileExtension = "data"

    static var rootDirectory: URL = {
        let fm = fileManager

        let caches = (
            try? fm.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        ) ?? fm.temporaryDirectory

        return caches
            .appendingPathComponent("sdk.adapty.io", isDirectory: true)
    }()

    @inlinable
    static func directoryName(forProfileId profileId: String) -> String {
        profileId.sha256.hexString
    }

    @inlinable
    static func directory(forProfileId profileId: String) -> URL {
        rootDirectory
            .appendingPathComponent(directoryName(forProfileId: profileId), isDirectory: true)
    }

    @inlinable
    static func directory(forProfileId profileId: String, itemType: Cache.ItemType) -> URL {
        directory(forProfileId: profileId)
            .appendingPathComponent(itemType.rawValue, isDirectory: true)
    }
}
