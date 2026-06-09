//
//  AdaptyUI+Dev.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import AdaptyUIBuilder
import Foundation

public struct Dev_DeviceOverride: Sendable {

    public var kind: AdaptyUISchema.DeviceKind
    /// Logical points; maps to `Adapty.DeviceInfo.horizontal`.
    public var width: Int
    /// Logical points; maps to `Adapty.DeviceInfo.vertical`.
    public var height: Int

    public init(kind: AdaptyUISchema.DeviceKind, width: Int, height: Int) {
        self.kind = kind
        self.width = width
        self.height = height
    }
}

@MainActor
public extension AdaptyUI {
    static func dev_getOnboardingConfiguration(
        forOnboarding onboarding: AdaptyOnboarding,
        externalUrlsPresentation: AdaptyWebPresentation,
        inspectWebView: Bool
    ) throws -> OnboardingConfiguration {
        try AdaptyUI.getOnboardingConfiguration(
            forOnboarding: onboarding,
            externalUrlsPresentation: externalUrlsPresentation,
            inspectWebView: inspectWebView
        )
    }

    /// Developer-only variant of `getFlowConfiguration(forFlow:locale:...)` that overrides the
    /// device descriptor sent to the backend, so the backend selects the layout for the given
    /// device kind + resolution instead of the physical device's. Rendering still happens on the
    /// real screen.
    static func dev_getFlowConfiguration(
        forFlow flow: AdaptyFlow,
        deviceOverride: Dev_DeviceOverride?,
        locale: String? = nil,
        customLayoutId: String? = nil,
        loadTimeout: TimeInterval? = nil,
        products: [AdaptyPaywallProduct]? = nil,
        observerModeResolver: AdaptyObserverModeResolver? = nil,
        tagResolver: AdaptyUITagResolver? = nil,
        timerResolver: AdaptyTimerResolver? = nil,
        assetsResolver: AdaptyUIAssetsResolver? = nil,
        systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil
    ) async throws -> FlowConfiguration {
        let device = if let deviceOverride {
            Adapty.DeviceInfo(
                kind: deviceOverride.kind == .phone ? .phone : .tab,
                vertical: deviceOverride.height,
                horizontal: deviceOverride.width
            )
        } else {
            Adapty.DeviceInfo.current
        }

        return try await getFlowConfiguration(
            forFlow: flow,
            device: device,
            locale: locale,
            customLayoutId: customLayoutId,
            loadTimeout: loadTimeout,
            products: products,
            observerModeResolver: observerModeResolver,
            tagResolver: tagResolver,
            timerResolver: timerResolver,
            assetsResolver: assetsResolver,
            systemRequestsHandler: systemRequestsHandler
        )
    }
}

#endif
