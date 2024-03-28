//
//  OldFeaturesBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct OldFeaturesBlock {
        public let type: OldFeaturesBlockType
        public let items: [String: AdaptyUI.OldViewItem]

        public let orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]

        init(type: OldFeaturesBlockType, orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]) {
            self.type = type
            items = [String: AdaptyUI.OldViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }

    public enum OldFeaturesBlockType: String {
        case list
        case timeline
    }
}

extension AdaptyUI.OldFeaturesBlockType: Decodable {}
