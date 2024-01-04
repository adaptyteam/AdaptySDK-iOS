//
//  ProductObject.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.01.2024
//

import Foundation

extension AdaptyUI {
    public struct ProductObject {
        public let productId: String
        public let properties: [String: AdaptyUI.LocalizedViewItem]
        public let orderedProperties: [(key: String, value: AdaptyUI.LocalizedViewItem)]
        init(productId: String, orderedProperties: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            self.productId = productId
            properties = [String: AdaptyUI.LocalizedViewItem](orderedProperties, uniquingKeysWith: { f, _ in f })
            self.orderedProperties = orderedProperties
        }
    }
}
