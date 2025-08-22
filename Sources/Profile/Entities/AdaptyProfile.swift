//
//  AdaptyProfile.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public struct AdaptyProfile: Sendable {
    let userId: AdaptyUserId

    /// An identifier of a user in Adapty.
    public var profileId: String { userId.profileId }

    /// An identifier of a user in your system.
    public var customerUserId: String? { userId.customerId }

    package let segmentId: String
    package let isTestUser: Bool

    let codableCustomAttributes: AdaptyProfile.CustomAttributes?

    /// Previously set user custom attributes with `.updateProfile()` method.
    public let customAttributes: [String: any Sendable]

    /// The keys are access level identifiers configured by you in Adapty Dashboard. The values are Can be null if the customer has no access levels.
    public var accessLevels: [String: AccessLevel]

    /// The keys are product ids from a store. The values are information about subscriptions. Can be null if the customer has no subscriptions.
    public let subscriptions: [String: Subscription]

    /// The keys are product ids from the store. The values are arrays of information about consumables. Can be null if the customer has no purchases.
    public let nonSubscriptions: [String: [NonSubscription]]

    let version: Int64
}

extension AdaptyProfile {
    func isNewerOrEqualVersion(_ other: AdaptyProfile) -> Bool {
        version >= other.version
    }
}

extension VH<AdaptyProfile> {
    @inlinable
    func isNewerOrEqualVersion(_ other: VH<AdaptyProfile>) -> Bool {
        value.isNewerOrEqualVersion(other.value)
    }
}

extension AdaptyProfile: Hashable {
    public static func == (lhs: AdaptyProfile, rhs: AdaptyProfile) -> Bool {
        lhs.userId == rhs.userId
            && lhs.segmentId == rhs.segmentId
            && lhs.isTestUser == rhs.isTestUser
            && lhs.codableCustomAttributes == rhs.codableCustomAttributes
            && lhs.accessLevels == rhs.accessLevels
            && lhs.subscriptions == rhs.subscriptions
            && lhs.nonSubscriptions == rhs.nonSubscriptions
            && lhs.version == rhs.version
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(segmentId)
        hasher.combine(isTestUser)
        hasher.combine(codableCustomAttributes)
        hasher.combine(accessLevels)
        hasher.combine(subscriptions)
        hasher.combine(nonSubscriptions)
        hasher.combine(version)
    }
}

extension AdaptyProfile: CustomStringConvertible {
    public var description: String {
        "(id: \(userId), "
            + "segmentId: \(segmentId), isTestuser: \(isTestUser), "
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
        case isTestUser = "is_test_user"
        case attributes
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.attributes) {
            container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        }

        userId = try .init(
            profileId: container.decode(String.self, forKey: .profileId),
            customerId: container.decodeIfPresent(String.self, forKey: .customerUserId)
        )
        segmentId = try container.decode(String.self, forKey: .segmentId)
        isTestUser = try container.decodeIfPresent(Bool.self, forKey: .isTestUser) ?? false
        version = try container.decodeIfPresent(Int64.self, forKey: .version) ?? 0
        codableCustomAttributes = try container.decodeIfPresent(AdaptyProfile.CustomAttributes.self, forKey: .customAttributes)
        customAttributes = codableCustomAttributes?.convertToSimpleDictionary() ?? [:]
        accessLevels = try container.decodeIfPresent([String: AccessLevel].self, forKey: .accessLevels) ?? [:]
        subscriptions = try container.decodeIfPresent([String: Subscription].self, forKey: .subscriptions) ?? [:]
        nonSubscriptions = try container.decodeIfPresent([String: [NonSubscription]].self, forKey: .nonSubscriptions) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId.profileId, forKey: .profileId)
        try container.encodeIfPresent(userId.customerId, forKey: .customerUserId)
        try container.encode(segmentId, forKey: .segmentId)
        try container.encode(isTestUser, forKey: .isTestUser)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(codableCustomAttributes, forKey: .customAttributes)
        if accessLevels.isNotEmpty {
            try container.encode(accessLevels, forKey: .accessLevels)
        }
        if subscriptions.isNotEmpty {
            try container.encode(subscriptions, forKey: .subscriptions)
        }
        if nonSubscriptions.isNotEmpty {
            try container.encode(nonSubscriptions, forKey: .nonSubscriptions)
        }
    }
}
