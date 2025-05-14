//
//  AdaptyUI+Onboardings.swift
//
//
//  Created by Aleksei Valiano on 30.07.2024
//
//

import Adapty
import Foundation
import SwiftUI

public extension AdaptyUI {
    struct OnboardingConfiguration: Sendable {
        let onboarding: AdaptyOnboarding

        public var id: String { onboarding.placement.id }

        var url: URL { onboarding.viewConfiguration.url }
        var variationId: String { onboarding.variationId }
        var shouldTrackShown: Bool { onboarding.shouldTrackShown }

        init(onboarding: AdaptyOnboarding) {
            self.onboarding = onboarding
        }
    }
}

public extension AdaptyUI {
    static func getOnboardingConfiguration(
        forOnboarding onboarding: AdaptyOnboarding
    ) -> OnboardingConfiguration {
        OnboardingConfiguration(onboarding: onboarding)
    }

    @MainActor
    static func createOnboardingController(
        configuration: OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate
    ) -> AdaptyOnboardingController {
        AdaptyOnboardingController(
            configuration: configuration,
            delegate: delegate
        )
    }

    @MainActor
    static func createSplashController(
        configuration: OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate,
        placeholderDelegate: AdaptyOnboardingPlaceholderDelegate
    ) -> OnboardingSplashController {
        OnboardingSplashController(
            configuration: configuration,
            delegate: delegate,
            placeholderDelegate: placeholderDelegate
        )
    }
}
