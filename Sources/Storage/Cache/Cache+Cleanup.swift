//
//  Cache+Cleanup.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.05.2026.
//

import Foundation

@Cache.Actor
extension Cache {
    static func cleanup() {
        let fm = fileManager
        let rootDirectoryPath = rootDirectory.path
        guard
            fm.fileExists(atPath: rootDirectoryPath),
            let subdirectories = try? fm.contentsOfDirectory(atPath: rootDirectoryPath),
            !subdirectories.isEmpty
        else { return }

        let knownTypes = Set(ItemType.allCases.map(\.rawValue))
        for name in subdirectories {
            let directory = rootDirectory.appendingPathComponent(name, isDirectory: true)
            guard
                let itemTypes = try? fm.contentsOfDirectory(atPath: directory.path),
                !itemTypes.isEmpty
            else { continue }
            for type in itemTypes where !knownTypes.contains(type) {
                // remove unknown item types
                try? fm.removeItem(at: directory.appendingPathComponent(type, isDirectory: true))
            }
        }

        // remove unpaired meta/data files
        guard let enumerator = fm.enumerator(
            at: rootDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return }

        var metaFileUrls: [URL] = []
        var dataFileUrls: [URL] = []
        for case let url as URL in enumerator {
            switch url.pathExtension {
            case metaFileExtension: metaFileUrls.append(url)
            case dataFileExtension: dataFileUrls.append(url)
            default: break
            }
        }

        let dataFilePaths = Set(dataFileUrls.map(\.path))
        for metaFileURL in metaFileUrls {
            let dataFileURL = metaFileURL.deletingPathExtension().appendingPathExtension(dataFileExtension)
            if !dataFilePaths.contains(dataFileURL.path) {
                try? fm.removeItem(at: metaFileURL)
            }
        }

        let metaFilePaths = Set(metaFileUrls.map(\.path))
        for dataFileURL in dataFileUrls {
            let metaFileURL = dataFileURL.deletingPathExtension().appendingPathExtension(metaFileExtension)
            if !metaFilePaths.contains(metaFileURL.path) {
                try? fm.removeItem(at: dataFileURL)
            }
        }
    }
}
