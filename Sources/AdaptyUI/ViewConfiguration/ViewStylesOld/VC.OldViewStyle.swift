//
//  VC.OldViewStyle.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct OldViewStyle {
        let featuresBlock: OldFeaturesBlock?
        let productsBlock: OldProductsBlock
        let footerBlock: OldFooterBlock?
        let items: [String: OldViewItem]
    }
}

extension AdaptyUI.ViewConfiguration.OldViewStyle: Decodable {
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
        items = try [String: AdaptyUI.ViewConfiguration.OldViewItem](
            container.allKeys
                .filter {
                    BlockKeys(rawValue: $0.stringValue) == nil
                }
                .map {
                    try ($0.stringValue, value: container.decode(AdaptyUI.ViewConfiguration.OldViewItem.self, forKey: $0))
                },
            uniquingKeysWith: { $1 }
        )
        footerBlock = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.OldFooterBlock.self, forKey: CodingKeys(BlockKeys.footerBlock))
        featuresBlock = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.OldFeaturesBlock.self, forKey: CodingKeys(BlockKeys.featuresBlock))
        productsBlock = try container.decode(AdaptyUI.ViewConfiguration.OldProductsBlock.self, forKey: CodingKeys(BlockKeys.productsBlock))
    }
}

extension KeyedDecodingContainer where Key == AdaptyUI.ViewConfiguration.OldViewStyle.CodingKeys {
    struct OrderedItem: Decodable {
        let order: Int
    }

    func toOrderedItems(filter: (String) -> Bool) throws -> [(key: String, value: AdaptyUI.ViewConfiguration.OldViewItem)] {
        try allKeys
            .filter {
                filter($0.stringValue)
            }
            .map { key in
                try (
                    key: key.stringValue,
                    value: decode(AdaptyUI.ViewConfiguration.OldViewItem.self, forKey: key),
                    order: (try? decode(OrderedItem.self, forKey: key))?.order ?? 0
                )
            }
            .sorted(by: { first, second in
                first.order < second.order
            })
            .map {
                (key: $0.key, value: $0.value)
            }
    }
}
