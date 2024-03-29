//
//  OldCustomObject.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 07.08.2023
//

import Foundation

extension AdaptyUI {
    public struct OldCustomObject {
        public let type: String
        public let properties: [String: AdaptyUI.OldViewItem]
        public let orderedProperties: [(key: String, value: AdaptyUI.OldViewItem)]
        init(type: String, orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]) {
            self.type = type
            properties = [String: AdaptyUI.OldViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedProperties = orderedItems
        }
    }
}
