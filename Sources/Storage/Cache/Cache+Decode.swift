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
    static func read<T: Sendable>(
        _ key: ItemKey,
        accept: (@Sendable (_ existing: Meta) -> Bool)? = nil,
        decode: @StorageActor (Data) throws -> T
    ) -> T? {
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

        let decoded: T
        do {
            decoded = try decode(data)
        } catch {
            log.warn("Cached data decode failed: \(error). Self-heal pair. Remove invalid data.")
            fm.removeCacheItem(key: key)
            return nil
        }

        meta.syncLastAccessed()
        return decoded
    }

    static func writeOrRead<T: Sendable>(
        _ newData: Data,
        key: ItemKey,
        locale: AdaptyLocale? = nil,
        eligibleCrossABtest: Bool = false,
        dataVersion: Int,
        accept: (@Sendable (_ new: Meta, _ existing: Meta) -> Bool)? = nil,
        decode: @StorageActor (Bool, Data) throws -> T
    ) throws -> T {
        let now = Date()
        let newMeta = Meta(
            key: key,
            size: newData.count,
            locale: locale,
            eligibleCrossABtest: eligibleCrossABtest,
            dataVersion: dataVersion,
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

        let shouldUseNew: Bool =
            if let accept {
                accept(newMeta, existingMeta)
            } else {
                true
            }

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

@StorageActor
private extension FileManager {
    func readExistingOrWriteNew<T: Sendable>(
        newData: Data,
        newMeta: Cache.Meta,
        existingMeta: Cache.Meta,
        decode: @StorageActor (Bool, Data) throws -> T
    ) throws -> T {
        let metaFileURL = existingMeta.key.metaFileURL
        let dataFileURL = existingMeta.key.dataFileURL

        if let data = try? Data(contentsOf: dataFileURL) {
            do {
                let decoded = try decode(false, data)
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
        decode: @StorageActor (Bool, Data) throws -> T
    ) throws -> T {
        let decodedNew: T
        do {
            decodedNew = try decode(true, newData)
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
        decode: @StorageActor (Bool, Data) throws -> T
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
            decodedCached = try decode(false, data)
        } catch {
            log.warn("Cached data decode failed: \(error). Remove invalid data. Return previous error.")
            removeCacheItem(metaFileURL: metaFileURL, dataFileURL: dataFileURL)
            throw fallbackError
        }

        existingMeta.syncLastAccessed()
        return decodedCached
    }
}

