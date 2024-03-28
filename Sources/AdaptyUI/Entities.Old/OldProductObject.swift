//
//  OldProductObject.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.01.2024
//

import Foundation

extension AdaptyUI {
    public struct OldProductObject {
        public let productId: String
        public let properties: [String: AdaptyUI.OldViewItem]
        public let orderedProperties: [(key: String, value: AdaptyUI.OldViewItem)]
        init(productId: String, orderedProperties: [(key: String, value: AdaptyUI.OldViewItem)]) {
            self.productId = productId
            properties = [String: AdaptyUI.OldViewItem](orderedProperties, uniquingKeysWith: { f, _ in f })
            self.orderedProperties = orderedProperties
        }
    }
}
