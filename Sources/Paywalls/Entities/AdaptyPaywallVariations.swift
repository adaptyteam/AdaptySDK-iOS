//
//  AdaptyPaywallVariations.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

enum AdaptyPaywallVariations: Sendable {
    struct Meta: Sendable, Decodable {
        let version: Int64

        enum CodingKeys: String, CodingKey {
            case version = "response_created_at"
        }
    }
}

extension AdaptyPaywallVariations {
    static func paywall(from decoder: Decoder, index: Int) throws -> AdaptyPaywall {
        struct Empty: Decodable {}

        var array = try decoder.unkeyedContainer()
        while !array.isAtEnd {
            if array.currentIndex == index {
                return try array.decode(AdaptyPaywall.self)
            }
            _ = try array.decode(Empty.self)
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywall with index \(index) not found"))
    }

    private static func variationIds(from decoder: Decoder) throws -> [String] {
        return try [Variation](from: decoder).map(\.variationId)

        struct Variation: Sendable, Decodable {
            let variationId: String

            enum CodingKeys: String, CodingKey {
                case variationId = "variation_id"
                case attributes
            }

            init(from decoder: Decoder) throws {
                var container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.attributes) {
                    container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
                }
                variationId = try container.decode(String.self, forKey: .variationId)
            }
        }
    }
}

extension AdaptyPaywallVariations {
    struct Value: Sendable, Decodable {
        let paywall: AdaptyPaywall?

        init(from decoder: Decoder) throws {
            let variationId = try decoder.userInfo.paywallVariationId
            let index = try variationIds(from: decoder).firstIndex { $0 == variationId }

            paywall = if let index {
                try AdaptyPaywallVariations.paywall(from: decoder, index: index)
            } else {
                nil
            }
        }
    }
}
