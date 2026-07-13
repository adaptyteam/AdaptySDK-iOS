//
//  AdaptyOnboarding.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

import Foundation

public struct AdaptyOnboarding: PlacementContent, Identifiable {

    public let placement: AdaptyPlacement

    public let id: String

    public let variationId: String

    /// A onboarding name.
    public let name: String

    public let remoteConfig: AdaptyRemoteConfig?

    public var hasViewConfiguration: Bool {
        true
    }

    package let viewConfigurationUrl: URL

    package var shouldTrackShown: Bool {
        placement.shouldTrackOnboardingShown
    }

    var requestLocale: AdaptyLocale

    package var requestLocaleIdentifier: String {
        requestLocale.normalizedIdentifier
    }
}

extension AdaptyOnboarding: CustomStringConvertible {
    public var description: String {
        "(onboarding, placement:\(placement), id: \(id), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration), requestLocale: \(requestLocale.id))"
    }
}

extension AdaptyOnboarding: Codable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case id = "onboarding_id"
        case variationId = "variation_id"
        case name = "onboarding_name"
        case remoteConfig = "remote_config"
        case viewConfiguration = "onboarding_builder"
        case requestLocale = "request_locale"
        case viewConfigurationUrl = "config_url"
    }

    public init(from decoder: Decoder) throws {
        try self.init(
            from: decoder,
            configuration: .init(
                userId: nil,
                placement: AdaptyPlacement(from: decoder),
                requestLocale: nil,
                variationId: nil
            )
        )
    }

    public init(from decoder: Decoder, configuration: AdaptyPlacement.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let viewConfiguration = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .viewConfiguration)
        try self.init(
            placement: configuration.placement,
            id: container.decode(String.self, forKey: .id),
            variationId: container.decode(String.self, forKey: .variationId),
            name: container.decode(String.self, forKey: .name),
            remoteConfig: container.decodeIfPresent(AdaptyRemoteConfig.self, forKey: .remoteConfig),
            viewConfigurationUrl: viewConfiguration.decode(URL.self, forKey: .viewConfigurationUrl),
            requestLocale: configuration.requestLocale ?? container.decode(AdaptyLocale.self, forKey: .requestLocale)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        try container.encodeIfPresent(remoteConfig, forKey: .remoteConfig)
        var viewConfiguration = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .viewConfiguration)
        try viewConfiguration.encode(viewConfigurationUrl, forKey: .viewConfigurationUrl)
        try container.encode(requestLocale, forKey: .requestLocale)
        try placement.encode(to: encoder)
    }
}

