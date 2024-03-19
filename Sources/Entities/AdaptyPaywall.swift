//
//  AdaptyPaywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public struct AdaptyPaywall {
    /// An identifier of a placement, configured in Adapty Dashboard.
    public let placementId: String

    public let instanceIdentity: String

    /// A paywall name.
    public let name: String

    /// Parent A/B test name.
    public let abTestName: String

    /// An identifier of a variation, used to attribute purchases to this paywall.
    public let variationId: String

    /// Current revision (version) of a paywall. Every change within a paywall creates a new revision.
    public let revision: Int

    /// If `true`, it is possible to fetch the view ``AdaptyUI.ViewConfiguration`` object and use it with ``AdaptyUI`` library.
    public let hasViewConfiguration: Bool

    /// And identifier of a paywall locale.
    public let locale: String

    /// A custom JSON string configured in Adapty Dashboard for this paywall.
    public let remoteConfigString: String?

    /// A custom dictionary configured in Adapty Dashboard for this paywall (same as `remoteConfigString`)
    public var remoteConfig: [String: Any]? {
        guard let data = remoteConfigString?.data(using: .utf8),
              let remoteConfig = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return nil }
        return remoteConfig
    }

    var products: [ProductReference]

    /// Array of related products ids.
    public var vendorProductIds: [String] { products.map { $0.vendorId } }
    let version: Int64
}

extension AdaptyPaywall: CustomStringConvertible {
    public var description: String {
        "(placementId: \(placementId), instanceIdentity: \(instanceIdentity), name: \(name), abTestName: \(abTestName), variationId: \(variationId), revision: \(revision), hasViewConfiguration: \(hasViewConfiguration), locale: \(locale), "
            + (remoteConfigString.map { "remoteConfig: \($0), " } ?? "")
            + "vendorProductIds: [\(vendorProductIds.joined(separator: ", "))])"
    }
}

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
        case remoteConfigLocale = "lang"
        case remoteConfigString = "data"
        case version = "paywall_updated_at"
        case hasViewConfiguration = "use_paywall_builder"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        placementId = try container.decode(String.self, forKey: .placementId)
        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        version = try container.decode(Int64.self, forKey: .version)
        revision = try container.decode(Int.self, forKey: .revision)
        variationId = try container.decode(String.self, forKey: .variationId)
        abTestName = try container.decode(String.self, forKey: .abTestName)
        products = try container.decode([ProductReference].self, forKey: .products)
        hasViewConfiguration = try container.decodeIfPresent(Bool.self, forKey: .hasViewConfiguration) ?? false

        if let remoteConfig = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .remoteConfig) {
            locale = try (remoteConfig.decode(AdaptyLocale.self, forKey: .remoteConfigLocale)).id
            remoteConfigString = try remoteConfig.decodeIfPresent(String.self, forKey: .remoteConfigString)
        } else {
            let requestLocale = decoder.userInfo[Backend.Request.localeCodeUserInfoKey] as? AdaptyLocale
            locale = (requestLocale ?? AdaptyLocale.defaultPaywallLocale).languageCode.lowercased()
            remoteConfigString = nil
        }
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
        try container.encode(hasViewConfiguration, forKey: .hasViewConfiguration)
        var remoteConfig = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .remoteConfig)
        try remoteConfig.encode(locale, forKey: .remoteConfigLocale)
        try remoteConfig.encodeIfPresent(remoteConfigString, forKey: .remoteConfigString)
    }
}

extension Sequence<VH<AdaptyPaywall>> {
    var asPaywallByPlacementId: [String: VH<AdaptyPaywall>] {
        Dictionary(map { ($0.value.placementId, $0) }, uniquingKeysWith: { first, second in
            first.value.version > second.value.version ? first : second
        })
    }
}
