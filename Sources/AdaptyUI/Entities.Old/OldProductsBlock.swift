//
//  OldProductsBlock.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct OldProductsBlock {
        public let type: ProductsBlockType
        public let mainProductIndex: Int
        public let initiatePurchaseOnTap: Bool
        public let products: [String: AdaptyUI.OldProductObject]
        public let items: [String: AdaptyUI.OldViewItem]
        public let orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]

        init(type: ProductsBlockType, mainProductIndex: Int, initiatePurchaseOnTap: Bool, products: [AdaptyUI.OldProductObject], orderedItems: [(key: String, value: AdaptyUI.OldViewItem)]) {
            self.type = type
            self.mainProductIndex = mainProductIndex
            self.initiatePurchaseOnTap = initiatePurchaseOnTap
            self.products = [String: AdaptyUI.OldProductObject](products.map { ($0.productId, $0) }, uniquingKeysWith: { f, _ in f })
            items = [String: AdaptyUI.OldViewItem](orderedItems, uniquingKeysWith: { f, _ in f })
            self.orderedItems = orderedItems
        }
    }

    public enum ProductsBlockType: String {
        case single
        case vertical
        case horizontal
    }
}

extension AdaptyUI.OldProductsBlock {
    public func product(by: AdaptyPaywallProduct) -> AdaptyUI.OldProductObject? {
        products[by.adaptyProductId]
    }

    public func products(by: AdaptyPaywall) -> [AdaptyUI.OldProductObject] {
        by.products.compactMap { products[$0.adaptyProductId] }
    }
}

extension AdaptyUI.ProductsBlockType: Decodable {}
