//
//  AdaptyFlowPaywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.03.2026.
//

import Foundation

public struct AdaptyFlowPaywall: Sendable, WebPaywallURLProviding, Identifiable {
    public let placement: AdaptyPlacement

    public let id: String

    /// An identifier of a variation, used to attribute purchases to this paywall.
    public let variationId: String

    /// A paywall name.
    public let name: String

    let products: [AdaptyFlowPaywall.ProductReference]

    package var webPaywallBaseUrl: URL?

    /// Array of related products ids.
    public var vendorProductIds: [String] {
        products.map(\.productInfo.vendorId)
    }
}

extension AdaptyFlowPaywall: CustomStringConvertible {
    public var description: String {
        "(paywall, placement:\(placement), id: \(id), name: \(name), variationId: \(variationId))"
    }
}

extension AdaptyFlowPaywall: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case id = "paywall_id"
        case name = "paywall_name"
        case variationId = "variation_id"
        case webPaywallBaseUrl = "web_purchase_url"
        case products
    }

    public init(from decoder: Decoder, configuration: AdaptyFlow.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placement = configuration.placement
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        variationId = try container.decode(String.self, forKey: .variationId)
        webPaywallBaseUrl = try container.decodeIfPresent(URL.self, forKey: .webPaywallBaseUrl)

        products = try {
            var arrayContainer = try container.nestedUnkeyedContainer(forKey: .products)
            var products = [AdaptyFlowPaywall.ProductReference]()
            var index = 0

            while !arrayContainer.isAtEnd {
                let product = try AdaptyFlowPaywall.ProductReference(
                    from: arrayContainer.nestedContainer(keyedBy: AdaptyFlowPaywall.ProductReference.CodingKeys.self),
                    index: index
                )
                index += 1
                products.append(product)
            }

            return products
        }()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        try container.encode(products, forKey: .products)
        try container.encodeIfPresent(webPaywallBaseUrl, forKey: .webPaywallBaseUrl)
    }
}

