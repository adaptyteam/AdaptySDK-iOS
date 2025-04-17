//
//  AdaptyUI+Onboardings.swift
//
//
//  Created by Aleksei Valiano on 30.07.2024
//
//

import Foundation
import SwiftUI

public extension AdaptyUI {
    struct OnboardingConfiguration: Sendable, Identifiable {
        public var id: String { url.absoluteString }
        
        let url = URL(string: "https://public_live_lzjhlp9e.octopusbuilder.com/onboarding-fitness-app-small/")!
    }
}

public extension AdaptyUI {
    static func createOnboardingConfiguration(id: String) async throws -> OnboardingConfiguration {
        return OnboardingConfiguration()
    }

    @MainActor
    static func createOnboardingController(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate
    ) async throws -> OnboardingController {
        let vc = OnboardingController(
            url: configuration.url,
            delegate: delegate
        )

        return vc
    }

    @MainActor
    static func createSplashController(
        configuration: OnboardingConfiguration,
        delegate: OnboardingDelegate,
        splashDelegate: OnboardingSplashDelegate
    ) -> OnboardingSplashController {
        OnboardingSplashController(
            configuration: configuration,
            delegate: delegate,
            splashDelegate: splashDelegate
        )
    }

    @MainActor
    static func swiftuiView<Splash: SwiftUI.View>(
        configuration: OnboardingConfiguration,
        splashViewBuilder: @escaping () -> Splash,
        onCloseAction: @escaping (OnboardingsCloseAction) -> Void,
        onOpenPaywallAction: ((OnboardingsOpenPaywallAction) -> Void)? = nil,
        onCustomAction: ((OnboardingsCustomAction) -> Void)? = nil,
        onStateUpdatedAction: ((OnboardingsStateUpdatedAction) -> Void)? = nil,
        onAnalyticsEvent: ((OnboardingsAnalyticsEvent) -> Void)? = nil,
        onError: @escaping (Error) -> Void
    ) -> some SwiftUI.View {
        OnboardingSplashView(
            configuration: configuration,
            splashViewBuilder: splashViewBuilder,
            onCloseAction: onCloseAction,
            onOpenPaywallAction: onOpenPaywallAction,
            onCustomAction: onCustomAction,
            onStateUpdatedAction: onStateUpdatedAction,
            onAnalyticsEvent: onAnalyticsEvent,
            onError: onError
        )
    }
}
