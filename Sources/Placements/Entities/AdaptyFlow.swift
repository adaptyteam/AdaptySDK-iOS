//
//  AdaptyFlow.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation
import AdaptyCodable

public struct AdaptyFlow: PlacementContent, Identifiable {
    public let placement: AdaptyPlacement
    public let id: String
    public let variationId: String
    public let name: String
    public let remoteConfigs: [AdaptyRemoteConfig]

    public var hasViewConfiguration: Bool {
        viewConfigurationId != nil
    }
    let viewConfigurationId: String?

    let paywalls: [AdaptyFlowPaywall]
}

extension AdaptyFlow: CustomStringConvertible {
    public var description: String {
        "(flow, placement:\(placement), id: \(id), name: \(name), variationId: \(variationId), hasViewConfiguration: \(hasViewConfiguration))"
    }
}

extension AdaptyFlow: Encodable, Decodable, DecodableWithConfiguration {

    public typealias DecodingConfiguration = AdaptyPlacement.DecodingConfiguration

    enum CodingKeys: String, CodingKey {
        case id = "flow_id"
        case variationId = "variation_id"
        case name = "flow_name"
        case remoteConfigs = "remote_configs"
        case paywalls = "variations"
        case viewConfigurationId = "flow_version_id"
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
        try self.init(
            placement: configuration.placement,
            id: container.decode(String.self, forKey: .id),
            variationId: container.decode(String.self, forKey: .variationId),
            name: container.decode(String.self, forKey: .name),
            remoteConfigs: container.decodeIfPresent([AdaptyRemoteConfig].self, forKey: .remoteConfigs) ?? [],
            viewConfigurationId: container.decodeIfPresent(String.self, forKey: .viewConfigurationId),
            paywalls: container.decodeIfExist([AdaptyFlowPaywall].self, forKey: .paywalls, configuration: configuration) ?? []
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(variationId, forKey: .variationId)
        if remoteConfigs.isNotEmpty {
            try container.encode(remoteConfigs, forKey: .remoteConfigs)
        }
        try container.encodeIfPresent(viewConfigurationId, forKey: .viewConfigurationId)
        try container.encode(paywalls, forKey: .paywalls)
        try placement.encode(to: encoder)
    }
}

