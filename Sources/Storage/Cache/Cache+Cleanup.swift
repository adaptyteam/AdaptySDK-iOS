//
//  Cache+Cleanup.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.05.2026.
//

import Foundation

@Cache.Actor
extension Cache {
    @inlinable
    static func cleanup(profileId: String) {
        let fm = fileManager
        guard
            fm.fileExists(atPath: rootDirectory.path),
            let profileIds = try? fm.contentsOfDirectory(atPath: rootDirectory.path),
            !profileIds.isEmpty
        else { return }

        // remove old profiles data
        let currentDirName = directoryName(forProfileId: profileId)
        for id in profileIds where id != currentDirName {
            try? fm.removeItem(at: rootDirectory.appendingPathComponent(id, isDirectory: true))
        }

        let currentDir = directory(forProfileId: profileId)
        guard
            fm.fileExists(atPath: currentDir.path),
            let itemTypes = try? fm.contentsOfDirectory(atPath: currentDir.path),
            !itemTypes.isEmpty
        else { return }

        let knownTypes = Set(ItemType.allCases.map(\.rawValue))
        // remove unknown item types
        for type in itemTypes where !knownTypes.contains(type) {
            try? fm.removeItem(at: currentDir.appendingPathComponent(type, isDirectory: true))
        }

        // remove unpaired meta/data files
        guard let enumerator = fm.enumerator(
            at: currentDir,
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
