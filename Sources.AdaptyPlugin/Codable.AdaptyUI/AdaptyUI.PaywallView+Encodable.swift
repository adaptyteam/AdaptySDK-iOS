//
//  AdaptyUI.PaywallView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

extension AdaptyUI.PaywallView: Encodable {
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
