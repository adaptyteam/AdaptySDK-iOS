//
//  Cache+WriteOrRead.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.05.2026.
//

import Foundation

private let log = Log.cache

@Cache.Actor
extension Cache {
    static func writeOrRead<T: Sendable>(
        _ newData: Data,
        key: ItemKey,
        locale: String? = nil,
        dataHash: String? = nil,
        accept: @Sendable (_ new: Meta, _ existing: Meta) -> Bool,
        decode: @Sendable (Data) throws -> T
    ) throws -> T {
        let now = Date()
        let newMeta = Meta(
            key: key,
            size: newData.count,
            locale: locale,
            dataHash: dataHash,
            storedAt: now,
            lastAccessedAt: now
        )

        let fm = fileManager
        let existingMeta: Meta? = fm.readValidatedCacheMeta(for: key)

        guard let existingMeta else {
            return try fm.writeNewOrReturnExisting(
                newData: newData,
                newMeta: newMeta,
                existingMeta: nil,
                decode: decode
            )
        }

        let shouldUseNew: Bool = accept(newMeta, existingMeta)

        if shouldUseNew {
            return try fm.writeNewOrReturnExisting(
                newData: newData,
                newMeta: newMeta,
                existingMeta: existingMeta,
                decode: decode
            )
        } else {
            return try fm.readExistingOrWriteNew(
                newData: newData,
                newMeta: newMeta,
                existingMeta: existingMeta,
                decode: decode
            )
        }
    }
}

@Cache.Actor
private extension FileManager {
    func readExistingOrWriteNew<T: Sendable>(
        newData: Data,
        newMeta: Cache.Meta,
        existingMeta: Cache.Meta,
        decode: @Sendable (Data) throws -> T
    ) throws -> T {
        let metaFileURL = existingMeta.key.metaFileURL
        let dataFileURL = existingMeta.key.dataFileURL

        if let data = try? Data(contentsOf: dataFileURL) {
            do {
                let decoded = try decode(data)
                existingMeta.syncLastAccessed()
                return decoded
            } catch {
                log.warn("Cached data decode failed: \(error). Remove invalid data. Self-heal + try new.")
                removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
            }
        } else {
            log.warn("Cached data read failed. Remove invalid data. Self-heal + try new.")
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
        }

        return try writeNewOrReturnExisting(
            newData: newData,
            newMeta: newMeta,
            existingMeta: nil,
            decode: decode
        )
    }

    func writeNewOrReturnExisting<T: Sendable>(
        newData: Data,
        newMeta: Cache.Meta,
        existingMeta: Cache.Meta?,
        decode: @Sendable (Data) throws -> T
    ) throws -> T {
        let decodedNew: T
        do {
            decodedNew = try decode(newData)
        } catch {
            guard let existingMeta else {
                log.warn("New data decode failed: \(error)")
                throw error
            }
            log.warn("New data decode failed: \(error) Self-heal + try existing.")
            return try readExistingOrFallbackError(
                existingMeta: existingMeta,
                fallbackError: error,
                decode: decode
            )
        }

        do {
            try writeCacheItem(
                data: newData,
                meta: newMeta,
                oldDataSize: existingMeta?.size ?? 0
            )
        } catch {
            log.warn("Write data failed (new data still returned): \(error)")
        }
        return decodedNew
    }

    private func readExistingOrFallbackError<T: Sendable>(
        existingMeta: Cache.Meta,
        fallbackError: Error,
        decode: @Sendable (Data) throws -> T
    ) throws -> T {
        let metaFileURL = existingMeta.key.metaFileURL
        let dataFileURL = existingMeta.key.dataFileURL

        guard let data = try? Data(contentsOf: dataFileURL) else {
            log.warn("Cached data read failed. Remove invalid data. Return previous error.")
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
            throw fallbackError
        }

        let decodedCached: T
        do {
            decodedCached = try decode(data)
        } catch {
            log.warn("Cached data decode failed: \(error). Remove invalid data. Return previous error.")
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
            throw fallbackError
        }

        existingMeta.syncLastAccessed()
        return decodedCached
    }
}
