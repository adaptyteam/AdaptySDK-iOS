//
//  VC.If.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct If: Decodable {
        let content: AdaptyUI.ViewConfiguration.Element

        enum CodingKeys: String, CodingKey {
            case platform
            case version
            case then
            case `else`
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            content =
                if
                    try container.decodeIfPresent(String.self, forKey: .platform).map({ $0 == "ios" }) ?? true,
                    try container.decodeIfPresent(String.self, forKey: .version).map(AdaptyUI.configurationFormatVersion.isSameOrNewerVersion) ?? true {
                    try container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .then)
                } else {
                    try container.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .else)
                }
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
