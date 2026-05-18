//
//  Cache.ItemKey.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.05.2026.
//

import Foundation

extension Cache {
    struct ItemKey: Hashable, Sendable {
        let profileId: String?
        let itemType: ItemType
        let itemId: String
    }
}

extension Cache.ItemKey {
    @inlinable
    var filename: String {
        itemId.sha256.hexString
    }
}

@Cache.Actor
extension Cache.ItemKey {
    @inlinable
    var directory: URL {
        Cache.directory(forProfileId: profileId, itemType: itemType)
    }

    @inlinable
    var metaFileURL: URL {
        directory
            .appendingPathComponent(filename)
            .appendingPathExtension(Cache.metaFileExtension)
    }

    @inlinable
    var dataFileURL: URL {
        directory
            .appendingPathComponent(filename)
            .appendingPathExtension(Cache.dataFileExtension)
    }
}
