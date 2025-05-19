//
//  AdaptyUI+Onboardings.swift
//
//
//  Created by Aleksei Valiano on 30.07.2024
//
//

#if canImport(UIKit)

import Adapty
import Foundation
import SwiftUI

public extension AdaptyUI {
    @MainActor
    final class OnboardingConfiguration {
        let viewModel: AdaptyOnboardingViewModel

        init(
            logId: String,
            onboarding: AdaptyOnboarding
        ) {
            Log.ui.verbose("#\(logId)# init onboarding: \(onboarding.placement.id)")

            self.viewModel = AdaptyOnboardingViewModel(
                logId: logId,
                onboarding: onboarding
            )
        }
    }
}

@MainActor
public extension AdaptyUI {
    static func getOnboardingConfiguration(
        forOnboarding onboarding: AdaptyOnboarding
    ) -> OnboardingConfiguration {
        OnboardingConfiguration(
            logId: Log.stamp,
            onboarding: onboarding
        )
    }

    @MainActor
    static func createOnboardingController(
        configuration: OnboardingConfiguration,
        delegate: AdaptyOnboardingControllerDelegate,
        statusBarStyle: UIStatusBarStyle = .lightContent
    ) -> AdaptyOnboardingController {
        AdaptyOnboardingController(
            configuration: configuration,
            delegate: delegate,
            statusBarStyle: statusBarStyle
        )
    }
}

#endif
