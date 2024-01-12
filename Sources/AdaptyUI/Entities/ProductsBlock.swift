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
        public let initiatePurchaseOnTap: Bool
        public let products: [String: AdaptyUI.ProductObject]
        public let items: [String: AdaptyUI.LocalizedViewItem]
        public let orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]

        init(type: ProductsBlockType, mainProductIndex: Int, initiatePurchaseOnTap: Bool, products: [AdaptyUI.ProductObject], orderedItems: [(key: String, value: AdaptyUI.LocalizedViewItem)]) {
            self.type = type
            self.mainProductIndex = mainProductIndex
            self.initiatePurchaseOnTap = initiatePurchaseOnTap
            self.products = [String: AdaptyUI.ProductObject](products.map { ($0.productId, $0) }, uniquingKeysWith: { f, _ in f })
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

extension AdaptyUI.ProductsBlock {
    public func product(by: AdaptyPaywallProduct) -> AdaptyUI.ProductObject? {
        products[by.adaptyProductId]
    }

    public func products(by: AdaptyPaywall) -> [AdaptyUI.ProductObject] {
        by.products.compactMap { products[$0.adaptyProductId] }
    }
}
