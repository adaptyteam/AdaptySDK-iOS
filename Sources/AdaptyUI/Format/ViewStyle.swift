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
        case textRows(TextRows)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewStyle {
    struct FooterBlock {
        let items: [String: AdaptyUI.ViewItem]
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
        let allKeys = container.allKeys
        var items = [String: AdaptyUI.ViewItem]()
        items.reserveCapacity(allKeys.count)
        for key in allKeys {
            guard BlockKeys(rawValue: key.stringValue) == nil else { continue }
            items[key.stringValue] = try container.decode(AdaptyUI.ViewItem.self, forKey: key)
        }
        self.items = items
        footerBlock = try container.decodeIfPresent(FooterBlock.self, forKey: CodingKeys(BlockKeys.footerBlock))
        featuresBlock = try container.decodeIfPresent(FeaturesBlock.self, forKey: CodingKeys(BlockKeys.featuresBlock))
        productsBlock = try container.decode(ProductsBlock.self, forKey: CodingKeys(BlockKeys.productsBlock))
    }
}

extension AdaptyUI.ViewStyle.FooterBlock: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        items = try container.decode([String: AdaptyUI.ViewItem].self)
    }
}

extension AdaptyUI.ViewStyle.FeaturesBlock: Decodable {
    enum PropertyKeys: String {
        case type
    }

    init(from decoder: Decoder) throws {
        typealias CodingKeys = AdaptyUI.ViewStyle.CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let allKeys = container.allKeys
        var items = [String: AdaptyUI.ViewItem]()
        items.reserveCapacity(allKeys.count)
        for key in allKeys {
            guard PropertyKeys(rawValue: key.stringValue) == nil else { continue }
            items[key.stringValue] = try container.decode(AdaptyUI.ViewItem.self, forKey: key)
        }
        self.items = items
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
        let allKeys = container.allKeys
        var items = [String: AdaptyUI.ViewItem]()
        items.reserveCapacity(allKeys.count)
        for key in allKeys {
            guard PropertyKeys(rawValue: key.stringValue) == nil else { continue }
            items[key.stringValue] = try container.decode(AdaptyUI.ViewItem.self, forKey: key)
        }
        self.items = items
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
        case button
        case textRows = "text-rows"
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
        case .shape:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Button.self))
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
        case .textRows:
            self = .textRows(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.TextRows.self))
        default:
            self = .unknown(type)
        }
    }
}
