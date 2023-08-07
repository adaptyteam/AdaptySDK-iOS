//
//  FeaturesBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct FeaturesBlock {
        public let type: FeaturesBlockType
        public let items: [String: AdaptyUI.LocalizedViewItem]

        public let orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]

        init(type: FeaturesBlockType, orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            self.type = type
            items = [String: AdaptyUI.LocalizedViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }

    public enum FeaturesBlockType: String {
        case list
        case timeline
    }
}
