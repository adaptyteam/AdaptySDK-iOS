//
//  AdaptyPaywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public struct AdaptyPaywall: Sendable, WebPaywallURLProviding {
    /// An identifier of a placement, configured in Adapty Dashboard.
    public let placementId: String

    public let instanceIdentity: String

    /// A paywall name.
    public let name: String

    /// Parent A/B test name.
    public let abTestName: String

    public let audienceName: String

    /// An identifier of a variation, used to attribute purchases to this paywall.
    public let variationId: String

    /// Current revision (version) of a paywall. Every change within a paywall creates a new revision.
    public let revision: Int

    public let remoteConfig: AdaptyPaywall.RemoteConfig?

    /// If `true`, it is possible to fetch the view ``AdaptyViewConfiguration`` object and use it with ``AdaptyUI`` library.
    public var hasViewConfiguration: Bool { viewConfiguration != nil }

    let viewConfiguration: ViewConfiguration?

    let products: [ProductReference]

    /// Array of related products ids.
    public var vendorProductIds: [String] { products.map { $0.vendorId } }

    package var webPaywallBaseUrl: URL?
    var version: Int64
}

extension AdaptyPaywall: CustomStringConvertible {
    public var description: String {
        "(placementId: \(placementId), instanceIdentity: \(instanceIdentity), name: \(name), abTestName: \(abTestName), audienceName: \(audienceName), variationId: \(variationId), revision: \(revision), hasViewConfiguration: \(hasViewConfiguration), "
            + (remoteConfig.map { "remoteConfig: \($0), " } ?? "")
            + "vendorProductIds: [\(vendorProductIds.joined(separator: ", "))])"
    }
}

extension AdaptyPaywall: ValueHashable {}

extension AdaptyPaywall: Codable {
    enum CodingKeys: String, CodingKey {
        case placementId = "developer_id"
        case instanceIdentity = "paywall_id"
        case revision
        case variationId = "variation_id"
        case abTestName = "ab_test_name"
        case name = "paywall_name"
        case products
        case remoteConfig = "remote_config"
        case version = "response_created_at"
        case viewConfiguration = "paywall_builder"
        case attributes
        case audienceName = "audience_name"
        case webPaywallBaseUrl = "web_purchase_url"
    }

    fileprivate func extractedFunc(
        _ arrayContainer: inout any UnkeyedDecodingContainer,
    ) throws -> [ProductReference] {
        var index = 0
        var products = [ProductReference]()

        while !arrayContainer.isAtEnd {
            let container = try arrayContainer.nestedContainer(keyedBy: ProductReference.CodingKeys.self)

            let promotionalOfferId: String? =
                if (try? container.decode(Bool.self, forKey: .promotionalOfferEligibility)) ?? true {
                    try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
                } else {
                    nil
                }
            try products.append(
                ProductReference(
                    paywallProductIndex: index,
                    adaptyProductId: container.decode(String.self, forKey: .adaptyProductId),
                    vendorId: container.decode(String.self, forKey: .vendorId),
                    promotionalOfferId: promotionalOfferId,
                    winBackOfferId: container.decodeIfPresent(String.self, forKey: .winBackOfferId)
                )
            )
            index += 1
        }

        return products
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.attributes) {
            container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        }

        placementId = try container.decode(String.self, forKey: .placementId)
        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        version = try container.decodeIfPresent(Int64.self, forKey: .version) ?? 0
        revision = try container.decode(Int.self, forKey: .revision)
        variationId = try container.decode(String.self, forKey: .variationId)
        abTestName = try container.decode(String.self, forKey: .abTestName)

        audienceName = try container.decode(String.self, forKey: .audienceName)
        remoteConfig = try container.decodeIfPresent(RemoteConfig.self, forKey: .remoteConfig)
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
        try container.encode(placementId, forKey: .placementId)
        try container.encode(instanceIdentity, forKey: .instanceIdentity)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(revision, forKey: .revision)
        try container.encode(variationId, forKey: .variationId)
        try container.encode(abTestName, forKey: .abTestName)
        try container.encode(products, forKey: .products)
        try container.encode(audienceName, forKey: .audienceName)
        try container.encodeIfPresent(remoteConfig, forKey: .remoteConfig)
        try container.encodeIfPresent(webPaywallBaseUrl, forKey: .webPaywallBaseUrl)
        try container.encodeIfPresent(viewConfiguration, forKey: .viewConfiguration)
    }
}

extension Sequence<VH<AdaptyPaywall>> {
    var asPaywallByPlacementId: [String: VH<AdaptyPaywall>] {
        Dictionary(map { ($0.value.placementId, $0) }, uniquingKeysWith: { first, second in
            first.value.version > second.value.version ? first : second
        })
    }
}
