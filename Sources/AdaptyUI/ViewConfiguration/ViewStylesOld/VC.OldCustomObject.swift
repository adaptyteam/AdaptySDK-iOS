//
//  VC.OldCustomObject.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct OldCustomObject {
        let type: String
        let properties: [(key: String, value: OldViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func oldCustomObject(_ from: AdaptyUI.ViewConfiguration.OldCustomObject) -> AdaptyUI.OldCustomObject {
        .init(
            type: from.type,
            orderedItems: orderedOldViewItems(from.properties)
        )
    }
}

extension AdaptyUI.ViewConfiguration.OldCustomObject: Decodable {
    enum PropertyKeys: String {
        case type
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.OldViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        type = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.type))
    }
}
