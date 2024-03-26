//
//  VC.FeaturesBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct FeaturesBlock {
        let type: AdaptyUI.OldFeaturesBlockType
        let orderedItems: [(key: String, value: ViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.FeaturesBlock: Decodable {
    enum PropertyKeys: String {
        case type
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems {
            PropertyKeys(rawValue: $0) == nil
        }
        type = try container.decode(AdaptyUI.OldFeaturesBlockType.self, forKey: CodingKeys(PropertyKeys.type))
    }
}
