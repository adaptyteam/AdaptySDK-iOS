//
//  VC.StringId.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

extension AdaptyViewSource {
    enum StringId: Sendable {
        case basic(String)
        case product(Product)
    }
}

extension AdaptyViewSource.StringId {
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

        static func calculate(
            adaptyProductId: String,
            byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode,
            suffix: String?
        ) -> String {
            let mode = mode.encodedValue ?? "default"
            return if let suffix {
                "PRODUCT_\(adaptyProductId)_\(mode)_\(suffix)"
            } else {
                "PRODUCT_\(adaptyProductId)_\(mode)"
            }
        }

        static func calculate(
            byPaymentMode mode: AdaptySubscriptionOffer.PaymentMode,
            suffix: String?)
        -> String {
            let mode = mode.encodedValue ?? "default"
            return if let suffix {
                "PRODUCT_\(mode)_\(suffix)"
            } else {
                "PRODUCT_\(mode)"
            }
        }
    }
}

extension AdaptyViewSource.StringId: Hashable {
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

extension AdaptyViewSource.StringId: Codable {
    init(from decoder: Decoder) throws {
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

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .basic(string):
            try container.encode(string)
        case let .product(product):
            try container.encode(product)
        }
    }
}

extension AdaptyViewSource.StringId.Product: Codable {
    static let typeValue = "product"
    enum CodingKeys: String, CodingKey {
        case type
        case productGroupId = "group_id"
        case adaptyProductId = "id"
        case suffix
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        guard type == Self.typeValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "is not equeal \"\(Self.typeValue)\" "))
        }

        adaptyProductId = try container.decodeIfPresent(String.self, forKey: .adaptyProductId)
        productGroupId = try container.decodeIfPresent(String.self, forKey: .productGroupId)
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.typeValue, forKey: .type)
        try container.encodeIfPresent(productGroupId, forKey: .productGroupId)
        try container.encodeIfPresent(adaptyProductId, forKey: .adaptyProductId)
        try container.encodeIfPresent(suffix, forKey: .suffix)
    }
}
