//
//  VC.OldProductsBlock.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct OldProductsBlock {
        let type: AdaptyUI.ProductsBlockType
        let mainProductIndex: Int
        let initiatePurchaseOnTap: Bool
        let products: [OldProductObject]
        let orderedItems: [(key: String, value: OldViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration {
    struct OldProductObject {
        let productId: String
        let orderedItems: [(key: String, value: OldViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func oldProductBlock(_ from: AdaptyUI.ViewConfiguration.OldProductsBlock) -> AdaptyUI.OldProductsBlock {
        .init(
            type: from.type,
            mainProductIndex: from.mainProductIndex,
            initiatePurchaseOnTap: from.initiatePurchaseOnTap,
            products: from.products.map(oldProductObject),
            orderedItems: orderedOldViewItems(from.orderedItems)
        )
    }

    private func oldProductObject(_ from: AdaptyUI.ViewConfiguration.OldProductObject) -> AdaptyUI.OldProductObject {
        .init(
            productId: from.productId,
            orderedItems: orderedOldViewItems(from.orderedItems)
        )
    }
}

extension AdaptyUI.ViewConfiguration.OldProductsBlock: Decodable {
    enum PropertyKeys: String {
        case type
        case mainProductIndex = "main_product_index"
        case initiatePurchaseOnTap = "initiate_purchase_on_tap"
        case products
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.OldViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems {
            PropertyKeys(rawValue: $0) == nil
        }
        type = try container.decode(AdaptyUI.ProductsBlockType.self, forKey: CodingKeys(PropertyKeys.type))
        mainProductIndex = try container.decodeIfPresent(Int.self, forKey: CodingKeys(PropertyKeys.mainProductIndex)) ?? 0
        initiatePurchaseOnTap = try container.decodeIfPresent(Bool.self, forKey: CodingKeys(PropertyKeys.initiatePurchaseOnTap)) ?? false
        products = try container.decodeIfPresent([AdaptyUI.ViewConfiguration.OldProductObject].self, forKey: CodingKeys(PropertyKeys.products)) ?? []
    }
}

extension AdaptyUI.ViewConfiguration.OldProductObject: Decodable {
    enum PropertyKeys: String {
        case type
        case productId = "product_id"
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.OldViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        productId = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.productId))
    }
}
