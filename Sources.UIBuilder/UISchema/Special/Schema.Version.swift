//
//  Schema.Version.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

package extension Schema {
    typealias Version = String // TODO: optimize - create struct with int array
}

extension Schema.Version {
    private var asIntArray: [Int] {
        self.components(separatedBy: CharacterSet(charactersIn: " -.")).map { Int($0) ?? 0 }
    }

    func isSameOrNewerVersion(than older: Self) -> Bool {
        self.asIntArray.isSameOrNewerVersion(than: older.asIntArray)
    }

    var isNotLegacyVersion: Bool {
        self.asIntArray.isSameOrNewerVersion(than: [4, 8])
    }
}

private extension [Int] {
    func isSameOrNewerVersion(than older: Self) -> Bool {
        var newer = self
        let diffCount = older.count - newer.count
        if diffCount > 0 {
            newer.append(contentsOf: repeatElement(0, count: diffCount))
        }
        for (index, newerElement) in newer.enumerated() {
            guard older.indices.contains(index) else { return true }
            let olderElement = older[index]
            if newerElement > olderElement { return true }
            if newerElement < olderElement { return false }
        }

        return true
    }
}
