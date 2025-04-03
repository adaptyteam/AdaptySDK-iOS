//
//  AdaptyPaywallVariations.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

enum AdaptyPaywallVariations {
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
}
