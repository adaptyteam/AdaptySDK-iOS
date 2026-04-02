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

    let paywalls: [AdaptyFlowPaywall]

    let viewConfiguration: ViewConfiguration?
}

extension AdaptyFlow: CustomStringConvertible {
    public var description: String {
        "(flow, placement:\(placement), instanceIdentity: \(instanceIdentity), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration))"
    }
}

extension AdaptyFlow: Encodable, Decodable,  DecodableWithConfiguration {

    public struct DecodingConfiguration {
        let placement: AdaptyPlacement
    }

    enum CodingKeys: String, CodingKey {
        case instanceIdentity = "flow_id"
        case variationId = "variation_id" //
        case name = "flow_name"

        case remoteConfigs = "remote_configs"
        case paywalls = "variations"
        case viewConfigurationExist = "flow_version_config_url"
    }

    public init(from decoder: Decoder) throws {
        let configuration = try  DecodingConfiguration(placement: AdaptyPlacement(from: decoder))
        try self.init(from: decoder, configuration: configuration)
    }

    public init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
        placement = configuration.placement
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
        paywalls = try container.decodeIfPresent([AdaptyFlowPaywall].self, forKey: .paywalls, configuration: configuration) ?? []
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
        try container.encode(paywalls, forKey: .paywalls)
        try placement.encode(to: encoder)
    }
}

