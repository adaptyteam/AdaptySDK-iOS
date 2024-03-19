//
//  AdaptyProfile.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public struct AdaptyProfile {
    /// An identifier of a user in Adapty.
    public let profileId: String

    /// An identifier of a user in your system.
    public let customerUserId: String?

    let segmentId: String

    let codableCustomAttributes: AdaptyProfile.CustomAttributes?

    /// Previously set user custom attributes with `.updateProfile()` method.
    public let customAttributes: [String: Any]

    /// The keys are access level identifiers configured by you in Adapty Dashboard. The values are Can be null if the customer has no access levels.
    public let accessLevels: [String: AccessLevel]

    /// The keys are product ids from a store. The values are information about subscriptions. Can be null if the customer has no subscriptions.
    public let subscriptions: [String: Subscription]

    /// The keys are product ids from the store. The values are arrays of information about consumables. Can be null if the customer has no purchases.
    public let nonSubscriptions: [String: [NonSubscription]]

    let version: Int64
}

extension AdaptyProfile: Equatable {
    public static func == (lhs: AdaptyProfile, rhs: AdaptyProfile) -> Bool {
        lhs.profileId == rhs.profileId
            && lhs.customerUserId == rhs.customerUserId
            && lhs.segmentId == rhs.segmentId
            && lhs.codableCustomAttributes == rhs.codableCustomAttributes
            && lhs.accessLevels == rhs.accessLevels
            && lhs.subscriptions == rhs.subscriptions
            && lhs.nonSubscriptions == rhs.nonSubscriptions
    }
}

extension AdaptyProfile: CustomStringConvertible {
    public var description: String {
        "(profileId: \(profileId), "
            + (customerUserId.map { "customerUserId: \($0), " } ?? "")
            + "segmentId: \(segmentId), "
            + (codableCustomAttributes == nil ? "" : "customAttributes: \(customAttributes), ")
            + "accessLevels: \(accessLevels), subscriptions: \(subscriptions), nonSubscriptions: \(nonSubscriptions))"
    }
}

extension AdaptyProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case customerUserId = "customer_user_id"
        case segmentId = "segment_hash"
        case customAttributes = "custom_attributes"
        case accessLevels = "paid_access_levels"
        case subscriptions
        case nonSubscriptions = "non_subscriptions"
        case version = "timestamp"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profileId = try container.decode(String.self, forKey: .profileId)
        customerUserId = try container.decodeIfPresent(String.self, forKey: .customerUserId)
        segmentId = try container.decode(String.self, forKey: .segmentId)
        version = try container.decodeIfPresent(Int64.self, forKey: .version) ?? 0
        codableCustomAttributes = try container.decodeIfPresent(AdaptyProfile.CustomAttributes.self, forKey: .customAttributes)
        customAttributes = codableCustomAttributes?.convertToSimpleDictionary() ?? [:]
        accessLevels = try container.decodeIfPresent([String: AccessLevel].self, forKey: .accessLevels) ?? [:]
        subscriptions = try container.decodeIfPresent([String: Subscription].self, forKey: .subscriptions) ?? [:]
        nonSubscriptions = try container.decodeIfPresent([String: [NonSubscription]].self, forKey: .nonSubscriptions) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profileId, forKey: .profileId)
        try container.encodeIfPresent(customerUserId, forKey: .customerUserId)
        try container.encode(segmentId, forKey: .segmentId)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(codableCustomAttributes, forKey: .customAttributes)
        if !accessLevels.isEmpty {
            try container.encode(accessLevels, forKey: .accessLevels)
        }
        if !subscriptions.isEmpty {
            try container.encode(subscriptions, forKey: .subscriptions)
        }
        if !nonSubscriptions.isEmpty {
            try container.encode(nonSubscriptions, forKey: .nonSubscriptions)
        }
    }
}
