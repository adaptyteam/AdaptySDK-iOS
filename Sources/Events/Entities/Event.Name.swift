//
//  Event.Name.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension Event {
    private enum Name: String, Sendable, Hashable {
        case appOpened = "app_opened"
        case paywallShowed = "paywall_showed"
        case legacyOnboardingScreenShowed = "onboarding_screen_showed"

        case system = "system_log"
        case paywallVariationAssigned = "paywall_variation_assigned"
        case onboardingVariationAssigned = "onboarding_variation_assigned"
        case onboardingScreenShowed = "new_onboarding_screen_showed"

        case profileRefundSaverSettings = "profile_refund_saver_settings"
    }

    var name: String {
        let name: Name =
            switch self {
            case .appOpened:
                .appOpened
            case .paywallShowed:
                .paywallShowed
            case .legacyOnboardingScreenShowed:
                .legacyOnboardingScreenShowed
            case .system:
                .system
            case .paywallVariationAssigned:
                .paywallVariationAssigned
            case .onboardingVariationAssigned:
                .onboardingVariationAssigned
            case .onboardingScreenShowed:
                .onboardingScreenShowed
            case .сonsentToCollectingRefundData:
                .profileRefundSaverSettings
            case .refundPreference:
                .profileRefundSaverSettings
            }

        return name.rawValue
    }
}
