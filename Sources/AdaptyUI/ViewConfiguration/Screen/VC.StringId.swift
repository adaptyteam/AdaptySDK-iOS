//
//  VC.StringId.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum StringId: Sendable {
        case basic(String)
        case product(Product)
    }
}

extension AdaptyUI.ViewConfiguration.StringId {
    struct Product: Sendable, Hashable {
        static let defaultProductGroupId = "group_A"
        let adaptyProductId: String?
        let productGroupId: String?
        let suffix: String?

        static func calculate(suffix: String?) -> String {
            if let suffix {
                "PRODUCT_not_selected_\(suffix)"
            } else {
                "PRODUCT_not_selected"
            }
        }

        static func calculate(adaptyProductId: String, byPaymentMode mode: AdaptyProductDiscount.PaymentMode, suffix: String?) -> String {
            let mode = mode.asString ?? "default"
            return if let suffix {
                "PRODUCT_\(adaptyProductId)_\(mode)_\(suffix)"
            } else {
                "PRODUCT_\(adaptyProductId)_\(mode)"
            }
        }

        static func calculate(byPaymentMode mode: AdaptyProductDiscount.PaymentMode, suffix: String?) -> String {
            let mode = mode.asString ?? "default"
            return if let suffix {
                "PRODUCT_\(mode)_\(suffix)"
            } else {
                "PRODUCT_\(mode)"
            }
        }
    }
}

extension AdaptyUI.ViewConfiguration.StringId: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .basic(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .product(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

extension AdaptyUI.ViewConfiguration.StringId: Decodable {
    init(from decoder: any Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(String.self) {
            self = .basic(value)
            return
        }

        let type = try decoder.container(keyedBy: Product.CodingKeys.self).decode(String.self, forKey: .type)

        guard type == Product.typeValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [Product.CodingKeys.type], debugDescription: "unknown value"))
        }

        self = try .product(Product(from: decoder))
    }
}

extension AdaptyUI.ViewConfiguration.StringId.Product: Decodable {
    static let typeValue = "product"
    enum CodingKeys: String, CodingKey {
        case type
        case productGroupId = "group_id"
        case adaptyProductId = "id"
        case suffix
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        guard type == Self.typeValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "is not equeal \"\(Self.typeValue)\" "))
        }

        adaptyProductId = try container.decodeIfPresent(String.self, forKey: .adaptyProductId)
        productGroupId = try container.decodeIfPresent(String.self, forKey: .productGroupId)
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix)
    }
}
