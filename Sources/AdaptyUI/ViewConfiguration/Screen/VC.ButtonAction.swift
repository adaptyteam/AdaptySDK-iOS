//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum ButtonAction {
        case openUrl(StringId)
        case restore
        case custom(id: String)
        case select(productId: String)
        case purchase(productId: String)
        case purchaseSelectedProduct
        case close
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func buttonAction(_ from: AdaptyUI.ViewConfiguration.ButtonAction) -> AdaptyUI.ButtonAction {
        switch from {
        case let .openUrl(stringId):
            .openUrl(self.urlIfPresent(stringId))
        case .restore:
            .restore
        case let .custom(id: id):
            .custom(id: id)
        case let .select(productId: productId):
            .selectProductId(id: productId)
        case let .purchase(productId: productId):
            .purchaseProductId(id: productId)
        case .purchaseSelectedProduct:
            .purchaseSelectedProduct
        case .close:
            .close
        }
    }
}

extension AdaptyUI.ViewConfiguration.ButtonAction: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case customId = "custom_id"
        case productId = "product_id"
    }

    enum Types: String {
        case openUrl = "open_url"
        case restore
        case custom
        case close
        case selectProductId = "select_product"
        case purchaseProductId = "purchase_product"
        case purchaseSelectedProduct = "purchase_selected_product"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try Types(rawValue: container.decode(String.self, forKey: .type)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .openUrl:
            self = try .openUrl(container.decode(AdaptyUI.ViewConfiguration.StringId.self, forKey: .url))
        case .restore:
            self = .restore
        case .close:
            self = .close
        case .custom:
            self = try .custom(id: container.decode(String.self, forKey: .customId))
        case .purchaseSelectedProduct:
            self = .purchaseSelectedProduct
        case .selectProductId:
            self = try .select(productId: container.decode(String.self, forKey: .productId))
        case .purchaseProductId:
            self = try .purchase(productId: container.decode(String.self, forKey: .productId))
        }
    }
}
