//
//  Event.Name.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension Event {
    enum Name: String, Sendable, Hashable {
        case appOpened = "app_opened"
        case paywallShowed = "paywall_showed"
        case onboardingScreenShowed = "onboarding_screen_showed"
        case system = "system_log"
        case paywallVariationAssigned = "paywall_variation_assigned"
    }

    var name: Name {
        switch self {
        case .appOpened:
            .appOpened
        case .paywallShowed:
            .paywallShowed
        case .onboardingScreenShowed:
            .onboardingScreenShowed
        case .system:
            .system
        case .paywallVariationAssigned:
            .paywallVariationAssigned
        }
    }
}
