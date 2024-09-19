//
//  AdaptyPaywallProduct.PrivateDecodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

extension AdaptyPaywallProduct {
    struct PrivateObject: Sendable, Decodable {
        let vendorProductId: String
        let adaptyProductId: String
        let promotionalOfferId: String?
        let variationId: String
        let paywallABTestName: String
        let paywallName: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: AdaptyPaywallProduct.CodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            variationId = try container.decode(String.self, forKey: .paywallVariationId)
            paywallABTestName = try container.decode(String.self, forKey: .paywallABTestName)
            paywallName = try container.decode(String.self, forKey: .paywallName)
        }
    }

    init(from object: PrivateObject, underlying: AdaptyProduct) {
        self.init(
            adaptyProductId: object.adaptyProductId,
            underlying: underlying,
            promotionalOfferId: object.promotionalOfferId,
            variationId: object.variationId,
            paywallABTestName: object.paywallABTestName,
            paywallName: object.paywallName
        )
    }
}
