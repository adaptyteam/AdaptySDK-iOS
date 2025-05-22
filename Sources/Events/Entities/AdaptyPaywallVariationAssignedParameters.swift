//
//  AdaptyPaywallVariationAssignedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct AdaptyPaywallVariationAssignedParameters: Sendable {
    let variationId: String
    let viewConfigurationId: String?
    let placementAudienceVersionId: String
}

extension AdaptyPaywallVariationAssignedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"
        case placementAudienceVersionId = "placement_audience_version_id"
    }
}
