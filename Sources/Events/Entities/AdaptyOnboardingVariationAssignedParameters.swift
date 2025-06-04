//
//  AdaptyOnboardingVariationAssignedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 14.04.2025.
//

import Foundation

struct AdaptyOnboardingVariationAssignedParameters: Sendable {
    let variationId: String
    let placementAudienceVersionId: String
}

extension AdaptyOnboardingVariationAssignedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case placementAudienceVersionId = "placement_audience_version_id"
    }
}
