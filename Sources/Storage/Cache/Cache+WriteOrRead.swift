//
//  Cache+WriteOrRead.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.05.2026.
//

import Foundation

private let log = Log.cache

@StorageActor
extension Cache {
    static func writeOrRead(
        _ newData: Data,
        key: ItemKey,
        locale: AdaptyLocale? = nil,
        eligibleCrossABtest: Bool = false,
        segmentId: String? = nil,
        dataVersion: Int,
        accept: (@Sendable (_ new: Meta, _ existing: Meta) -> Bool)? = nil
    ) throws -> Data {
        let now = Date()
        let newMeta = Meta(
            key: key,
            size: newData.count,
            locale: locale,
            eligibleCrossABtest: eligibleCrossABtest,
            segmentId: segmentId,
            dataVersion: dataVersion,
            storedAt: now,
            lastAccessedAt: now
        )

        let fm = fileManager
        let existingMeta: Meta? = fm.readValidatedCacheMeta(for: key)

        guard let existingMeta else {
            fm.writeNew(
                newData: newData,
                newMeta: newMeta,
                existingMeta: nil
            )
            return newData
        }

        let shouldUseNew: Bool =
            if let accept {
                accept(newMeta, existingMeta)
            } else {
                true
            }

        if shouldUseNew {
            fm.writeNew(
                newData: newData,
                newMeta: newMeta,
                existingMeta: existingMeta
            )
            return newData
        } else {
            return try fm.readExistingOrWriteNew(
                newData: newData,
                newMeta: newMeta,
                existingMeta: existingMeta
            )
        }
    }
}

@StorageActor
private extension FileManager {
    func readExistingOrWriteNew(
        newData: Data,
        newMeta: Cache.Meta,
        existingMeta: Cache.Meta
    ) throws -> Data {
        let metaFileURL = existingMeta.key.metaFileURL
        let dataFileURL = existingMeta.key.dataFileURL

        if let data = try? Data(contentsOf: dataFileURL) {
            existingMeta.syncLastAccessed()
            return data
        } else {
            log.warn("Cached data read failed. Remove invalid data. Self-heal + try new.")
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
        }

        writeNew(
            newData: newData,
            newMeta: newMeta,
            existingMeta: existingMeta
        )

        return newData
    }

    func writeNew(
        newData: Data,
        newMeta: Cache.Meta,
        existingMeta: Cache.Meta?
    ) {
        do {
            try writeCacheItem(
                data: newData,
                meta: newMeta,
                oldDataSize: existingMeta?.size ?? 0
            )
        } catch {
            log.warn("Write data failed (new data still returned): \(error)")
        }
    }
}
