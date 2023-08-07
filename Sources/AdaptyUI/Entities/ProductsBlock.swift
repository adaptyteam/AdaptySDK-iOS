//
//  ProductsBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct ProductsBlock {
        public let type: ProductsBlockType
        public let mainProductIndex: Int
        public let items: [String: AdaptyUI.LocalizedViewItem]
        public let orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]

        init(type: ProductsBlockType, mainProductIndex: Int, orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            self.type = type
            self.mainProductIndex = mainProductIndex
            items = [String: AdaptyUI.LocalizedViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }

    public enum ProductsBlockType: String {
        case single
        case vertical
        case horizontal
    }
}
