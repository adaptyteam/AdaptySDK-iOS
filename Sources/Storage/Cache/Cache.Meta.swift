//
//  Cache.Meta.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.05.2026.
//

import Foundation

private let log = Log.cache

extension Cache {
    struct Meta: Sendable {
        let key: ItemKey
        let schemaVersion: Int

        let size: Int
        let storedAt: Date
        var lastAccessedAt: Date

        let dataVersion: Int
        let locale: String?

        init(
            key: ItemKey,
            size: Int,
            locale: String?,
            dataVersion: Int,
            storedAt: Date,
            lastAccessedAt: Date
        ) {
            self.key = key
            schemaVersion = key.itemType.schemaVersion
            self.size = size
            self.locale = locale
            self.dataVersion = dataVersion
            self.storedAt = storedAt
            self.lastAccessedAt = lastAccessedAt
        }
    }
}

extension Cache.Meta: Codable {
    private enum CodingKeys: String, CodingKey {
        case profileId = "profile"
        case itemType = "type"
        case itemId = "id"
        case schemaVersion = "format"
        case size
        case locale
        case dataVersion = "version"
        case storedAt = "stored_at"
        case lastAccessedAt = "last_accessed_at"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try .init(
            profileId: container.decodeIfPresent(String.self, forKey: .profileId),
            itemType: container.decode(Cache.ItemType.self, forKey: .itemType),
            itemId: container.decode(String.self, forKey: .itemId)
        )
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        size = try container.decode(Int.self, forKey: .size)
        locale = try container.decodeIfPresent(String.self, forKey: .locale)
        dataVersion = try container.decode(Int.self, forKey: .dataVersion)
        storedAt = try Date(timeIntervalSince1970: container.decode(Double.self, forKey: .storedAt))
        lastAccessedAt = try Date(timeIntervalSince1970: container.decode(Double.self, forKey: .lastAccessedAt))
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(key.profileId, forKey: .profileId)
        try container.encode(key.itemType, forKey: .itemType)
        try container.encode(key.itemId, forKey: .itemId)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(locale, forKey: .locale)
        try container.encode(dataVersion, forKey: .dataVersion)
        try container.encode(storedAt.timeIntervalSince1970, forKey: .storedAt)
        try container.encode(lastAccessedAt.timeIntervalSince1970, forKey: .lastAccessedAt)
    }
}

@Cache.Actor
extension Cache.Meta {
    @discardableResult
    @inlinable
    func syncLastAccessed() -> Self {
        var meta = self
        meta.lastAccessedAt = Date()
        do {
            try meta.write()
            return meta
        } catch {
            log.warn("Cannot rewrite meta: \(error)")
            return self
        }
    }

    @inlinable
    init(from url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try JSONDecoder().decode(Cache.Meta.self, from: data)
    }

    @inlinable
    func write() throws {
        let meta = try JSONEncoder().encode(self)
        try meta.write(to: key.metaFileURL,
                       options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}
