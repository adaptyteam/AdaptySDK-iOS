//
//  AdaptyPaywall.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public struct AdaptyPaywall {
    /// An identifier of a paywall, configured in Adapty Dashboard.
    public let id: String

    /// A paywall name.
    public let name: String

    /// Parent A/B test name.
    public let abTestName: String

    /// An identifier of a variation, used to attribute purchases to this paywall.
    public let variationId: String

    /// Current revision (version) of a paywall. Every change within a paywall creates a new revision.
    public let revision: Int

    /// A custom JSON string configured in Adapty Dashboard for this paywall.
    public let customPayloadString: String?

    /// A custom dictionary configured in Adapty Dashboard for this paywall (same as `customPayloadString`)
    public var customPayload: [String: Any]? {
        guard let data = customPayloadString?.data(using: .utf8),
              let customPayload = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return nil }
        return customPayload
    }

    var products: [BackendProduct]

    /// Array of related products ids.
    public var vendorProductIds: [String] { products.map { $0.vendorId } }
    let version: Int64
}

extension AdaptyPaywall: CustomStringConvertible {
    public var description: String {
        "(id: \(id), name: \(name), abTestName: \(abTestName), variationId: \(variationId), revision: \(revision), "
            + (customPayloadString == nil ? "" : "customPayload: \(customPayloadString!), ")
            + "vendorProductIds: [\(vendorProductIds.joined(separator: ", "))])"
    }
}

extension AdaptyPaywall: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "developer_id"
        case revision
        case variationId = "variation_id"
        case abTestName = "ab_test_name"
        case name = "paywall_name"
        case products
        case customPayloadString = "custom_payload"
        case version = "paywall_updated_at"
    }
}

extension Sequence where Element == AdaptyPaywall {
    var asDictionary: [String: AdaptyPaywall] {
        Dictionary(uniqueKeysWithValues: map { ($0.id, $0) })
    }
}

extension Sequence where Element == VH<AdaptyPaywall> {
    var asDictionary: [String: VH<AdaptyPaywall>] {
        Dictionary(uniqueKeysWithValues: map { ($0.value.id, $0) })
    }
}

extension AdaptyPaywall {
    func map(syncedBundleReceipt: Bool) -> Self {
        guard !syncedBundleReceipt else { return self }
        var paywall = self
        paywall.products = paywall.products.map(syncedBundleReceipt: syncedBundleReceipt)
        return paywall
    }
}

extension Array where Element == AdaptyPaywall {
    func map(syncedBundleReceipt: Bool) -> [AdaptyPaywall] {
        guard !syncedBundleReceipt else { return self }
        return map { $0.map(syncedBundleReceipt: syncedBundleReceipt) }
    }
}
