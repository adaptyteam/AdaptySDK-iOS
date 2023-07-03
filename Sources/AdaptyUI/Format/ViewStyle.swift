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
        let featuresBlock: FeaturesBlock
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
    enum CodingKeys: String, CodingKey, CaseIterable {
        case footerBlock = "footer_block"
        case featuresBlock = "features_block"
        case productsBlock = "products_block"
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        var items = try single.decode([String: AdaptyUI.ViewItem].self)
        for key in CodingKeys.allCases {
            items.removeValue(forKey: key.rawValue)
        }
        self.items = items

        let container = try decoder.container(keyedBy: CodingKeys.self)
        footerBlock = try container.decodeIfPresent(FooterBlock.self, forKey: .footerBlock)
        featuresBlock = try container.decode(FeaturesBlock.self, forKey: .featuresBlock)
        productsBlock = try container.decode(ProductsBlock.self, forKey: .productsBlock)
    }
}

extension AdaptyUI.ViewStyle.FooterBlock: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        items = try container.decode([String: AdaptyUI.ViewItem].self)
    }
}

extension AdaptyUI.ViewStyle.FeaturesBlock: Decodable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(AdaptyUI.FeaturesBlockType.self, forKey: .type)

        let single = try decoder.singleValueContainer()
        var items = try single.decode([String: AdaptyUI.ViewItem].self)
        for key in CodingKeys.allCases {
            items.removeValue(forKey: key.rawValue)
        }
        self.items = items
    }
}

extension AdaptyUI.ViewStyle.ProductsBlock: Decodable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case type
        case mainProductIndex = "main_product_index"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(AdaptyUI.ProductsBlockType.self, forKey: .type)
        mainProductIndex = try container.decodeIfPresent(Int.self, forKey: .mainProductIndex) ?? 0

        let single = try decoder.singleValueContainer()
        var items = try single.decode([String: AdaptyUI.ViewItem].self)
        for key in CodingKeys.allCases {
            items.removeValue(forKey: key.rawValue)
        }
        self.items = items
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
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }
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
            self = .unknown("item.type: \(type)")
        }
    }
}
