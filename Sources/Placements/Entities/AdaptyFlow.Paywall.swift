//
//  AdaptyFlow.Paywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.03.2026.
//

import Foundation

extension AdaptyFlow {
    struct Paywall: WebPaywallURLProviding {
        let instanceIdentity: String
        let name: String

        let variationId: String
        var webPaywallBaseUrl: URL?

        let products: [AdaptyFlow.ProductReference]

        var vendorProductIds: [String] {
            products.map(\.productInfo.vendorId)
        }
    }
}

extension AdaptyFlow.Paywall: CustomStringConvertible {
    var description: String {
        "(flow.paywall, instanceIdentity: \(instanceIdentity), name: \(name), variationId: \(variationId))"
    }
}

extension AdaptyFlow.Paywall: Codable {
    enum CodingKeys: String, CodingKey {
        case instanceIdentity = "paywall_id"
        case name = "paywall_name"
        case variationId = "variation_id"
        case webPaywallBaseUrl = "web_purchase_url"
        case products
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        variationId = try container.decode(String.self, forKey: .variationId)
        webPaywallBaseUrl = try container.decodeIfPresent(URL.self, forKey: .webPaywallBaseUrl)

        products = try {
            var arrayContainer = try container.nestedUnkeyedContainer(forKey: .products)
            var products = [AdaptyFlow.ProductReference]()
            var index = 0

            while !arrayContainer.isAtEnd {
                let product = try AdaptyFlow.ProductReference(
                    from: arrayContainer.nestedContainer(keyedBy: AdaptyFlow.ProductReference.CodingKeys.self),
                    index: index
                )
                index += 1
                products.append(product)
            }

            return products
        }()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceIdentity, forKey: .instanceIdentity)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        try container.encode(products, forKey: .products)
        try container.encodeIfPresent(webPaywallBaseUrl, forKey: .webPaywallBaseUrl)
    }
}

