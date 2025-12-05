//
//  Schema.If.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct If: Decodable {
        let content: Schema.Element

        enum CodingKeys: String, CodingKey {
            case platform
            case startVersion = "version"
            case endVersion = "to_version"
            case then
            case `else`
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var result = try container.decodeIfPresent(String.self, forKey: .platform).map { $0 == "ios" } ?? true

            if result, let startVersion = try container.decodeIfPresent(String.self, forKey: .startVersion) {
                result = Schema.formatVersion.isSameOrNewerVersion(than: startVersion)
            }

            if result, let endVersion = try container.decodeIfPresent(String.self, forKey: .endVersion) {
                result = !endVersion.isSameOrNewerVersion(than: Schema.formatVersion)
            } 

            content = try container.decode(Schema.Element.self, forKey: result ? .then : .else)
        }
    }
}

extension String {
    func isSameOrNewerVersion(than older: Self) -> Bool {
        func stringVersionToArray(_ value: String) -> [Int] {
            value.components(separatedBy: CharacterSet(charactersIn: " -.")).map { Int($0) ?? 0 }
        }
        return stringVersionToArray(self).isSameOrNewerVersion(than: stringVersionToArray(older))
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
