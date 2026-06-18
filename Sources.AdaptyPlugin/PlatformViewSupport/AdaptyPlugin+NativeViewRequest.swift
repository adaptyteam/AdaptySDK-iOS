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
    ) async throws -> AdaptyUI.FlowConfiguration {
        let request = try AdaptyPlugin.decoder.decode(
            Request.AdaptyUICreateFlowView.self,
            from: jsonString.asAdaptyJsonData
        )

        let systemRequestsHandler = AdaptyPlugin.sharedEventHandler
            .map(PluginSystemRequestsHandler.init(eventHandler:))
        // Only forward an observer-mode resolver in Observer Mode. Passing one in
        // Full Mode would make the SDK delegate every purchase to the host instead
        // of calling Adapty.makePurchase (the SDK gates on resolver presence, not
        // on the observer-mode flag).
        let observerModeResolver = AdaptyUI.isObserverModeEnabled
            ? AdaptyPlugin.sharedEventHandler.map(PluginObserverModeResolver.init(eventHandler:))
            : nil

        let configuration = try await AdaptyUI.getFlowConfiguration(
            forFlow: request.flow,
            loadTimeout: request.loadTimeout,
            observerModeResolver: observerModeResolver,
            tagResolver: request.customTags,
            timerResolver: request.customTimers,
            assetsResolver: request.customAssets?.assetsResolver(),
            systemRequestsHandler: systemRequestsHandler
        )

        // Platform views resolve their instance id only when the wrapper builds
        // the flow view (with the host-provided viewId). Hand the per-view
        // resolver/handler the config's late-bound identity box so their host
        // events carry the originating view.
        observerModeResolver?.identityBox = configuration.flowViewIdentityBox
        systemRequestsHandler?.identityBox = configuration.flowViewIdentityBox

        return configuration
    }

    @available(*, deprecated, message: "Onboarding Feature is deprecated.")
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
