//
//  AdaptyUI.View.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.View: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case placementId = "placement_id"
        case paywallVariationId = "paywall_variation_id"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(templateId, forKey: .templateId)
        try container.encode(placementId, forKey: .placementId)
        try container.encode(paywallVariationId, forKey: .paywallVariationId)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.View: AdaptyJsonDataRepresentable {
    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPaywallController {
    var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try toView().asAdaptyJsonData
        }
    }
}
