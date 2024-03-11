//
//  VC.CustomObject.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct CustomObject {
        let type: String
        let properties: [(key: String, value: ViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.CustomObject: Decodable {
    enum PropertyKeys: String {
        case type
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        type = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.type))
    }
}
