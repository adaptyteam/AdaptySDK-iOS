//
//  AdaptyUI.View.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.PaywallView: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case placementId = "placement_id"
        case variationId = "variation_id"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(placementId, forKey: .placementId)
        try container.encode(variationId, forKey: .variationId)
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.OnboardingView: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case placementId = "placement_id"
        case variationId = "variation_id"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(placementId, forKey: .placementId)
        try container.encode(variationId, forKey: .variationId)
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
