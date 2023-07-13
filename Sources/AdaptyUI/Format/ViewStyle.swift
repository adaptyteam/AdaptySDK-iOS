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
        case unknown(String?)
    }
}

extension AdaptyUI.ViewStyle {
    struct FooterBlock {
        let orderedItems: [(key: String, value: AdaptyUI.ViewItem)]
    }

    struct FeaturesBlock {
        let type: AdaptyUI.FeaturesBlockType
        let items: [String: AdaptyUI.ViewItem]
    }

    struct ProductsBlock {
        let type: AdaptyUI.ProductsBlockType
        let mainProductIndex: Int
        let items: [String: AdaptyUI.ViewItem]
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

extension AdaptyUI.ViewStyle.FooterBlock: Decodable {
    struct Order: Decodable {
        let order: Int
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderedItems = try container.allKeys
            .map { key in
                (key: key.stringValue,
                 value: try container.decode(AdaptyUI.ViewItem.self, forKey: key),
                 order: (try? container.decode(Order.self, forKey: key))?.order ?? 0)
            }
            .sorted(by: { first, second in
                first.order < second.order
            })
            .map {
                (key: $0.key, value: $0.value)
            }
    }
}

extension AdaptyUI.ViewStyle.FeaturesBlock: Decodable {
    enum PropertyKeys: String {
        case type
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)

        items = [String: AdaptyUI.ViewItem](
            try container.allKeys
                .filter {
                    PropertyKeys(rawValue: $0.stringValue) == nil
                }
                .map {
                    ($0.stringValue, try container.decode(AdaptyUI.ViewItem.self, forKey: $0))
                },
            uniquingKeysWith: { $1 }
        )

        type = try container.decode(AdaptyUI.FeaturesBlockType.self, forKey: CodingKeys(PropertyKeys.type))
    }
}

extension AdaptyUI.ViewStyle.ProductsBlock: Decodable {
    enum PropertyKeys: String {
        case type
        case mainProductIndex = "main_product_index"
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = [String: AdaptyUI.ViewItem](
            try container.allKeys
                .filter {
                    PropertyKeys(rawValue: $0.stringValue) == nil
                }
                .map {
                    ($0.stringValue, try container.decode(AdaptyUI.ViewItem.self, forKey: $0))
                },
            uniquingKeysWith: { $1 }
        )
        type = try container.decode(AdaptyUI.ProductsBlockType.self, forKey: CodingKeys(PropertyKeys.type))
        mainProductIndex = try container.decodeIfPresent(Int.self, forKey: CodingKeys(PropertyKeys.mainProductIndex)) ?? 0
    }
}

extension AdaptyUI.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
        case text

        case shape
        case rectangle
        case circle
        case curveUp = "curve_up"
        case curveDown = "curve_down"

        case button
        case textRows = "text-rows" // deprecated
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let assetId = try? single.decode(String.self) {
            self = .asset(assetId)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch ContentType(rawValue: type) {
        case .shape, .rectangle, .circle, .curveUp, .curveDown:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Button.self))
        case .text, .textRows:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
        default:
            self = .unknown(type)
        }
    }
}
