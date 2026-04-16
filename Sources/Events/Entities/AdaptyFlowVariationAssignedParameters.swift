//
//  AdaptyFlowVariationAssignedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct AdaptyFlowVariationAssignedParameters: Sendable {
    let variationId: String
    let viewConfigurationId: String?
    let placementAudienceVersionId: String
}

extension AdaptyFlowVariationAssignedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case viewConfigurationId = "flow_version_id"
        case placementAudienceVersionId = "placement_audience_version_id"
    }
}
