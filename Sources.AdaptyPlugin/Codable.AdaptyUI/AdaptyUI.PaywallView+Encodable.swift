//
//  AdaptyUI.FlowView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

extension AdaptyUI.FlowView: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case placementId = "placement_id"
        case variationId = "variation_id"
        case locale
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(placementId, forKey: .placementId)
        try container.encode(variationId, forKey: .variationId)
        try container.encodeIfPresent(locale, forKey: .locale)
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
