//
//  AdaptyPaywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

import Foundation

public struct AdaptyPaywall: AdaptyPlacementContent, WebPaywallURLProviding {
    public let placement: AdaptyPlacement

    public let instanceIdentity: String

    /// An identifier of a variation, used to attribute purchases to this paywall.
    public let variationId: String

    /// A paywall name.
    public let name: String

    public let remoteConfig: AdaptyRemoteConfig?

    /// If `true`, it is possible to fetch the view ``AdaptyViewConfiguration`` object and use it with ``AdaptyUI`` library.
    public var hasViewConfiguration: Bool { viewConfiguration != nil }

    let viewConfiguration: ViewConfiguration?

    let products: [ProductReference]

    package var webPaywallBaseUrl: URL?

    /// Array of related products ids.
    public var vendorProductIds: [String] { products.map { $0.vendorId } }
}

extension AdaptyPaywall: CustomStringConvertible {
    public var description: String {
        "(placement:\(placement), instanceIdentity: \(instanceIdentity), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration)"
            + (remoteConfig.map { ", remoteConfig: \($0)" } ?? "")
            + ", vendorProductIds: [\(vendorProductIds.joined(separator: ", "))])"
    }
}

extension AdaptyPaywall: Codable {
    enum CodingKeys: String, CodingKey {
        case instanceIdentity = "paywall_id"
        case variationId = "variation_id"
        case name = "paywall_name"
        case remoteConfig = "remote_config"
        case viewConfiguration = "paywall_builder"
        case webPaywallBaseUrl = "web_purchase_url"
        case products
    }

    public init(from decoder: Decoder) throws {

        placement = try decoder.userInfo.placementOrNil ?? AdaptyPlacement(from: decoder)

        let superContainer = try decoder.container(keyedBy: Backend.CodingKeys.self)
        
        let container =
            if superContainer.contains(.attributes) {
                try superContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            } else {
                try decoder.container(keyedBy: CodingKeys.self)
            }
        
        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        variationId = try container.decode(String.self, forKey: .variationId)
        remoteConfig = try container.decodeIfPresent(AdaptyRemoteConfig.self, forKey: .remoteConfig)
        webPaywallBaseUrl = try container.decodeIfPresent(URL.self, forKey: .webPaywallBaseUrl)
        viewConfiguration = try container.decodeIfPresent(ViewConfiguration.self, forKey: .viewConfiguration)
        
        products = try {
            var arrayContainer = try container.nestedUnkeyedContainer(forKey: .products)
            var products = [ProductReference]()
            var index = 0

            while !arrayContainer.isAtEnd {
                let product = try ProductReference(
                    from: arrayContainer.nestedContainer(keyedBy: ProductReference.CodingKeys.self),
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
        try container.encode(instanceIdentity, forKey: .instanceIdentity)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        try container.encodeIfPresent(remoteConfig, forKey: .remoteConfig)
        try container.encode(products, forKey: .products)
        try container.encodeIfPresent(webPaywallBaseUrl, forKey: .webPaywallBaseUrl)
        try container.encodeIfPresent(viewConfiguration, forKey: .viewConfiguration)
        try placement.encode(to: encoder)
    }
}

extension Sequence<VH<AdaptyPaywall>> {
    var asPaywallByPlacementId: [String: VH<AdaptyPaywall>] {
        Dictionary(map { ($0.value.placement.id, $0) }, uniquingKeysWith: { first, second in
            first.value.placement.version > second.value.placement.version ? first : second
        })
    }
}
