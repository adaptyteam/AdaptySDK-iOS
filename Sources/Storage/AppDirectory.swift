//
//  AppDirectory.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.12.2025.
//

import Foundation

@AdaptyActor
enum AppDirectory {
    static func applicationSupport(fileName: String) throws -> Data? {
        try load(fileName, for: .applicationSupportDirectory)
    }

    static func setApplicationSupport(data: Data, fileName: String) throws {
        try write(data, fileName, for: .applicationSupportDirectory, isExcludedFromBackup: true)
    }

    static func caches(fileName: String) throws -> Data? {
        try load(fileName, for: .cachesDirectory)
    }

    static func setCaches(data: Data, fileName: String) throws {
        try write(data, fileName, for: .cachesDirectory, isExcludedFromBackup: true)
    }

    private static func load(_ fileName: String, for dir: FileManager.SearchPathDirectory) throws -> Data? {
        let fileURL = try fileUrl(fileName, for: dir)
        return try? Data(contentsOf: fileURL)
    }

    private static func write(_ data: Data, _ fileName: String, for dir: FileManager.SearchPathDirectory, isExcludedFromBackup: Bool) throws {
        let fileURL = try fileUrl(fileName, for: dir)

        try data.write(
            to: fileURL,
            options: [.atomic, .completeFileProtection]
        )

        if isExcludedFromBackup {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            var mutableURL = fileURL
            try mutableURL.setResourceValues(resourceValues)
        }
    }

    private static func fileUrl(_ fileName: String, for dir: FileManager.SearchPathDirectory) throws -> URL {
        let fm = FileManager.default

        let url = try fm.url(
            for: dir,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        if !fm.fileExists(atPath: url.path) {
            try fm.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }

        return url.appendingPathComponent(fileName)
    }
}
