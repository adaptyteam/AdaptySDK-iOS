//
//  AdaptyOnboarding.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

import Foundation

public struct AdaptyOnboarding: AdaptyPlacementContent {
    public let placement: AdaptyPlacement

    public let instanceIdentity: String

    public let variationId: String

    /// A onboarding name.
    public let name: String

    public let remoteConfig: AdaptyRemoteConfig?

    public var hasViewConfiguration: Bool { true }

    package let viewConfiguration: ViewConfiguration

    package var shouldTrackShown: Bool { placement.shouldTrackOnboardingShown }
}

extension AdaptyOnboarding: CustomStringConvertible {
    public var description: String {
        "(placement:\(placement), instanceIdentity: \(instanceIdentity), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration)"
            + (remoteConfig.map { ", remoteConfig: \($0)" } ?? "")
            + ")"
    }
}

extension AdaptyOnboarding: Codable {
    enum CodingKeys: String, CodingKey {
        case instanceIdentity = "onboarding_id"
        case variationId = "variation_id"
        case name = "onboarding_name"
        case remoteConfig = "remote_config"
        case viewConfiguration = "onboarding_builder"
    }

    public init(from decoder: Decoder) throws {
        placement = try decoder.userInfo.placementOrNil ?? AdaptyPlacement(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        variationId = try container.decode(String.self, forKey: .variationId)
        remoteConfig = try container.decodeIfPresent(AdaptyRemoteConfig.self, forKey: .remoteConfig)
        viewConfiguration = try container.decode(ViewConfiguration.self, forKey: .viewConfiguration)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceIdentity, forKey: .instanceIdentity)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        try container.encodeIfPresent(remoteConfig, forKey: .remoteConfig)
        try container.encode(viewConfiguration, forKey: .viewConfiguration)
        try placement.encode(to: encoder)
    }
}

extension Sequence<VH<AdaptyOnboarding>> {
    var asOnboardingByPlacementId: [String: VH<AdaptyOnboarding>] {
        Dictionary(map { ($0.value.placement.id, $0) }, uniquingKeysWith: { first, second in
            first.value.placement.version > second.value.placement.version ? first : second
        })
    }
}
