//
//  VC.ProductsBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct ProductsBlock {
        let type: AdaptyUI.ProductsBlockType
        let mainProductIndex: Int
        let initiatePurchaseOnTap: Bool
        let products: [ProductObject]
        let orderedItems: [(key: String, value: ViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration {
    struct ProductObject {
        let productId: String
        let properties: [(key: String, value: ViewItem)]
    }
}

extension AdaptyUI.ViewConfiguration.ProductsBlock: Decodable {
    enum PropertyKeys: String {
        case type
        case mainProductIndex = "main_product_index"
        case initiatePurchaseOnTap = "initiate_purchase_on_tap"
        case products
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems {
            PropertyKeys(rawValue: $0) == nil
        }
        type = try container.decode(AdaptyUI.ProductsBlockType.self, forKey: CodingKeys(PropertyKeys.type))
        mainProductIndex = try container.decodeIfPresent(Int.self, forKey: CodingKeys(PropertyKeys.mainProductIndex)) ?? 0
        initiatePurchaseOnTap = try container.decodeIfPresent(Bool.self, forKey: CodingKeys(PropertyKeys.initiatePurchaseOnTap)) ?? false
        products = try container.decodeIfPresent([AdaptyUI.ViewConfiguration.ProductObject].self, forKey: CodingKeys(PropertyKeys.products)) ?? []
    }
}

extension AdaptyUI.ViewConfiguration.ProductObject: Decodable {
    enum PropertyKeys: String {
        case type
        case productId = "product_id"
        case order
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewConfiguration.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.toOrderedItems { PropertyKeys(rawValue: $0) == nil }
        productId = try container.decode(String.self, forKey: CodingKeys(PropertyKeys.productId))
    }
}
