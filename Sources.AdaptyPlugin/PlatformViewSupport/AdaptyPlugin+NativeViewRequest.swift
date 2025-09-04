//
//  AdaptyPlugin+NativeViewRequest.swift
//  Adapty
//
//  Created by Alexey Goncharov on 5/30/25.
//

import Adapty
import AdaptyUI
import Foundation

private let log = Log.plugin

// TODO: refactor this

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

    static func executeCreateNativeOnboardingView(withJson jsonString: AdaptyJsonString) async -> AdaptyOnboarding? {
        do {
            return try AdaptyPlugin.decoder.decode(
                AdaptyOnboarding.self,
                from: jsonString.asAdaptyJsonData
            )
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method: create_native_onboarding_view is invalid", error)
            log.error(error.message)
            return nil
        }
    }
}
