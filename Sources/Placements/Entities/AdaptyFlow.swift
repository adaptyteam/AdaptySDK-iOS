//
//  AdaptyFlow.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

public struct AdaptyFlow: PlacementContent {
    public let placement: AdaptyPlacement
    public let instanceIdentity: String
    public let variationId: String
    public let name: String
    public let remoteConfigs: [AdaptyRemoteConfig]

    public var hasViewConfiguration: Bool {
        viewConfiguration != nil
    }

    let viewConfiguration: ViewConfiguration?
    var requestLocale: AdaptyLocale
}

extension AdaptyFlow: CustomStringConvertible {
    public var description: String {
        "(flow, placement:\(placement), instanceIdentity: \(instanceIdentity), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration), requestLocale: \(requestLocale.id))"
    }
}

extension AdaptyFlow: Codable {
    enum CodingKeys: String, CodingKey {
        case instanceIdentity = "flow_id"
        case variationId = "variation_id" //
        case name = "flow_name"

        case remoteConfigs = "remote_configs"
        case requestLocale = "request_locale"

        case viewConfigurationExist = "flow_version_config_url"
    }

    public init(from decoder: Decoder) throws {
        placement = try decoder.userInfo.placementOrNil ?? AdaptyPlacement(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instanceIdentity = try container.decode(String.self, forKey: .instanceIdentity)
        name = try container.decode(String.self, forKey: .name)
        variationId = try container.decode(String.self, forKey: .variationId)
        remoteConfigs = try container.decodeIfPresent([AdaptyRemoteConfig].self, forKey: .remoteConfigs) ?? []

        if container.contains(.viewConfigurationExist) {
            viewConfiguration = try ViewConfiguration(from: decoder)
        } else {
            viewConfiguration = nil
        }
        requestLocale = try decoder.userInfo.requestLocaleOrNil ?? container.decode(AdaptyLocale.self, forKey: .requestLocale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceIdentity, forKey: .instanceIdentity)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        if remoteConfigs.isNotEmpty {
            try container.encode(remoteConfigs, forKey: .remoteConfigs)
        }
        if let viewConfiguration {
            try viewConfiguration.encode(to: encoder)
        }
        try container.encode(requestLocale, forKey: .requestLocale)
        try placement.encode(to: encoder)
    }
}

