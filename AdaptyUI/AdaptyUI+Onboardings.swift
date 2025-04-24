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
        public let id: String

        let url: URL
        let variationId: String
        let shouldTrackShown: Bool

        init(onboarding: AdaptyOnboarding) {
            id = onboarding.placement.id
            url = onboarding.viewConfiguration.url
            variationId = onboarding.variationId
            shouldTrackShown = onboarding.shouldTrackShown
        }

        // TODO: remove this method
        package init(id: String, url: URL) {
            self.id = id
            self.url = url
            self.variationId = "test"
            self.shouldTrackShown = true
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
