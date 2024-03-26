//
//  ButtonAction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    public enum ButtonAction {
        case openUrl(String?)
        case restore
        case custom(String?)
        case selectProduct(ProductIndexOrId)
        case purchaseProduct(ProductIndexOrId)
        case purchaseSelectedProduct
        case close

        public enum ProductIndexOrId {
            case index(Int)
            case id(String)
        }
    }
}

extension AdaptyUI.ButtonAction: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case customId = "custom_id"
        case productIndex = "product_index"
        case productId = "product_id"
    }

    enum Types: String {
        case openUrl = "open_url"
        case restore
        case custom
        case close
        case selectProduct = "select_product"
        case purchaseProduct = "purchase_product"
        case purchaseSelectedProduct = "purchase_selected_product"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try Types(rawValue: container.decode(String.self, forKey: .type)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .openUrl:
            self = try .openUrl(container.decode(String.self, forKey: .url))
        case .restore:
            self = .restore
        case .close:
            self = .close
        case .custom:
            self = try .custom(container.decode(String.self, forKey: .customId))
        case .purchaseSelectedProduct:
            self = .purchaseSelectedProduct
        case .selectProduct:
            self = try .selectProduct(productIndexOrId())
        case .purchaseProduct:
            self = try .purchaseProduct(productIndexOrId())
        }

        func productIndexOrId() throws -> ProductIndexOrId {
            if let id = try container.decodeIfPresent(String.self, forKey: .productId) {
                .id(id)
            } else if let index = try container.decodeIfPresent(Int.self, forKey: .productIndex) {
                .index(index)
            } else {
                try .id(container.decode(String.self, forKey: .productId))
            }
        }
    }
}
