//
//  AdaptyPlugin+NativeViewRequest.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/30/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import Foundation

private let log = Log.plugin

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension AdaptyPlugin {
    static func getPaywallViewConfiguration(
        withJson jsonString: AdaptyJsonString
    ) async throws -> AdaptyUI.PaywallConfiguration {
        let request = try AdaptyPlugin.decoder.decode(
            Request.AdaptyUICreatePaywallView.self,
            from: jsonString.asAdaptyJsonData
        )

        return try await AdaptyUI.getPaywallConfiguration(
            forPaywall: request.paywall,
            loadTimeout: request.loadTimeout,
            tagResolver: request.customTags,
            timerResolver: request.customTimers,
            assetsResolver: request.customAssets?.assetsResolver()
        )
    }

    static func getOnboardingViewConfiguration(
        withJson jsonString: AdaptyJsonString
    ) async throws -> AdaptyUI.OnboardingConfiguration {
        let request = try AdaptyPlugin.decoder.decode(
            Request.AdaptyUICreateOnboardingView.self,
            from: jsonString.asAdaptyJsonData
        )

        return try AdaptyUI.getOnboardingConfiguration(
            forOnboarding: request.onboarding,
            externalUrlsPresentation: request.externalUrlsPresentation
        )
    }
}

#endif
