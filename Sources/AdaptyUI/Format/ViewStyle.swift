//
//  ViewStyle.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    struct ViewStyle {
        let featuresBlock: FeaturesBlock?
        let productsBlock: ProductsBlock
        let footerBlock: FooterBlock?
        let items: [String: ViewItem]
    }

    enum ViewItem {
        case asset(String)
        case shape(Shape)
        case button(Button)
        case text(Text)
        case object(CustomObject)
        case unknown
    }
}

extension AdaptyUI.ViewStyle {
    struct FooterBlock {
        let orderedItems: [(key: String, value: AdaptyUI.ViewItem)]
    }

    struct FeaturesBlock {
        let type: AdaptyUI.FeaturesBlockType
        let orderedItems: [(key: String, value: AdaptyUI.ViewItem)]
    }

    struct ProductsBlock {
        let type: AdaptyUI.ProductsBlockType
        let mainProductIndex: Int
        let initiatePurchaseOnTap: Bool
        let products: [AdaptyUI.ViewItem.ProductObject]
        let orderedItems: [(key: String, value: AdaptyUI.ViewItem)]
    }
}

extension AdaptyUI.ViewStyle: Decodable {
    enum BlockKeys: String {
        case footerBlock = "footer_block"
        case featuresBlock = "features_block"
        case productsBlock = "products_block"
    }

    struct CodingKeys: CodingKey {
        let stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init<T: RawRepresentable>(_ value: T) where T.RawValue == String {
            stringValue = value.rawValue
        }

        var intValue: Int? { Int(stringValue) }

        init?(intValue: Int) {
            stringValue = String(intValue)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = [String: AdaptyUI.ViewItem](
            try container.allKeys
                .filter {
                    BlockKeys(rawValue: $0.stringValue) == nil
                }
                .map {
                    ($0.stringValue, value: try container.decode(AdaptyUI.ViewItem.self, forKey: $0))
                },
            uniquingKeysWith: { $1 }
        )
        footerBlock = try container.decodeIfPresent(FooterBlock.self, forKey: CodingKeys(BlockKeys.footerBlock))
        featuresBlock = try container.decodeIfPresent(FeaturesBlock.self, forKey: CodingKeys(BlockKeys.featuresBlock))
        productsBlock = try container.decode(ProductsBlock.self, forKey: CodingKeys(BlockKeys.productsBlock))
    }
}

extension KeyedDecodingContainer where Key == AdaptyUI.ViewStyle.CodingKeys {
    struct OrderedItem: Decodable {
        let order: Int
    }

    func toOrderedItems(filter: (String) -> Bool) throws -> [(key: String, value: AdaptyUI.ViewItem)] {
        try allKeys
            .filter {
                filter($0.stringValue)
            }
            .map { key in
                (key: key.stringValue,
                 value: try decode(AdaptyUI.ViewItem.self, forKey: key),
                 order: (try? decode(OrderedItem.self, forKey: key))?.order ?? 0)
            }
            .sorted(by: { first, second in
                first.order < second.order
            })
            .map {
                (key: $0.key, value: $0.value)
            }
    }
}

extension AdaptyUI.ViewStyle.FooterBlock: Decodable {
    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems { _ in true }
    }
}

extension AdaptyUI.ViewStyle.FeaturesBlock: Decodable {
    enum PropertyKeys: String {
        case type
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems {
            PropertyKeys(rawValue: $0) == nil
        }
        type = try container.decode(AdaptyUI.FeaturesBlockType.self, forKey: CodingKeys(PropertyKeys.type))
    }
}

extension AdaptyUI.ViewStyle.ProductsBlock: Decodable {
    enum PropertyKeys: String {
        case type
        case mainProductIndex = "main_product_index"
        case initiatePurchaseOnTap = "initiate_purchase_on_tap"
        case products
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.toOrderedItems {
            PropertyKeys(rawValue: $0) == nil
        }
        type = try container.decode(AdaptyUI.ProductsBlockType.self, forKey: CodingKeys(PropertyKeys.type))
        mainProductIndex = try container.decodeIfPresent(Int.self, forKey: CodingKeys(PropertyKeys.mainProductIndex)) ?? 0
        initiatePurchaseOnTap = try container.decodeIfPresent(Bool.self, forKey: CodingKeys(PropertyKeys.initiatePurchaseOnTap)) ?? false
        products = try container.decodeIfPresent([AdaptyUI.ViewItem.ProductObject].self, forKey: CodingKeys(PropertyKeys.products)) ?? []
    }
}

extension AdaptyUI.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
        case text

        case shape
        case rectangle = "rect"
        case circle
        case curveUp = "curve_up"
        case curveDown = "curve_down"

        case button
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let assetId = try? single.decode(String.self) {
            self = .asset(assetId)
            return
        }

        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            self = .unknown
            return
        }

        let type = try container.decode(String.self, forKey: .type)

        switch ContentType(rawValue: type) {
        case .shape, .rectangle, .circle, .curveUp, .curveDown:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Button.self))
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
        default:
            self = .object(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.CustomObject.self))
        }
    }
}
