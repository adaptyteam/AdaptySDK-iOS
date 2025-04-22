//
//  AdaptyOnboardingScreenShowedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 14.04.2025.
//

import Foundation

package struct AdaptyOnboardingScreenShowedParameters: Sendable {
    package let variationId: String
    package let screenName: String?
    package let screenOrder: String
    package let isLatestScreen: Bool
}

extension AdaptyOnboardingScreenShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case screenName = "onboarding_screen_name"
        case screenOrder = "onboarding_screen_order"
        case isLatestScreen = "onboarding_latest_screen"
    }
}
