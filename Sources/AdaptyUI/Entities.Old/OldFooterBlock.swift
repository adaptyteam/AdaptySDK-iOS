//
//  OldFooterBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    public struct OldFooterBlock {
        public let items: [String: AdaptyUI.OldViewItem]
        public let orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]
        init(orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]) {
            items = [String: AdaptyUI.OldViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }
}
