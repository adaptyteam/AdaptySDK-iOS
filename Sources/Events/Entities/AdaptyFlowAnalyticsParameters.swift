//
//  AdaptyFlowAnalyticsParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import AdaptyCodable
import AdaptyUIBuilder
import Foundation

package protocol AdaptyFlowAnalyticsPayload: Sendable, Encodable {}

struct AdaptyFlowAnalyticsParameters: Sendable {
    let variationId: String
    let flowVersionId: String?
    let payload: AdaptyFlowAnalyticsPayload
}

extension AdaptyFlowAnalyticsParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case flowVersionId = "flow_version_id"
        case payload = "event_properties"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(variationId, forKey: .variationId)
        try container.encodeIfPresent(flowVersionId, forKey: .flowVersionId)
        try container.encode(payload, forKey: .payload)
//        try payload.encode(to: container.superEncoder(forKey: .payload))
    }
}

package struct AdaptyUIFlowScreenShowedParameters: AdaptyFlowAnalyticsPayload {
    package let screenInstanceId: String
    package let screenOrder: Int
    package let isLatestScreen: Bool

    package init(screenInstanceId: String, screenOrder: Int, isLatestScreen: Bool) {
        self.screenInstanceId = screenInstanceId
        self.screenOrder = screenOrder
        self.isLatestScreen = isLatestScreen
    }

    enum CodingKeys: String, CodingKey {
        case name = "event_type"
        case screenInstanceId = "screen_id"
        case screenOrder = "screen_order"
        case isLatestScreen = "is_last_screen"
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("flow_screen_showed", forKey: .name)
        try container.encode(screenInstanceId, forKey: .screenInstanceId)
        try container.encode(screenOrder, forKey: .screenOrder)
        try container.encode(isLatestScreen, forKey: .isLatestScreen)
    }
}

extension VS.AnalyticEvent: AdaptyFlowAnalyticsPayload {
    private enum CodingKeys: String, CodingKey {
        case name = "event_type"
        case screenInstanceId = "screen_id"
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        var params = params
        for internalkey in ParamsInternalKeys.allCases {
            params.removeValue(forKey: internalkey.rawValue)
        }
        try container.encodeDictionary(params)

        try container.encode(name, forKey: .init(CodingKeys.name))
        try container.encodeIfPresent(screenInstanceId, forKey: .init(CodingKeys.screenInstanceId))
    }
}

