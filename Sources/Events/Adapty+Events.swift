//
//  Adapty+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty {
    @EventsManagerActor
    static let eventsManager = EventsManager()

    static func trackEvent(_ event: Event, for profileId: String? = nil) {
        let now = Date()
        let profileId = profileId ?? ProfileStorage.profileId
        Task.detached(priority: .utility) {
            let event = await Event.Unpacked(
                event: event,
                profileId: profileId,
                environment: Environment.instance,
                createdAt: now
            )
            try? await eventsManager.trackEvent(event)
        }
    }

    package static func trackSystemEvent(_ params: AdaptySystemEventParameters) {
        trackEvent(.system(params))
    }

    static func trackEventIfNeed(_ chosen: AdaptyPaywallChosen) {
        guard case let .draw(draw) = chosen else {
            return
        }

        Log.crossAB.verbose("-> trackEvent variationId = \(draw.paywall.variationId)")
        
        trackEvent(.paywallVariationAssigned(.init(
            paywallVariationId: draw.paywall.variationId,
            viewConfigurationId: draw.paywall.viewConfiguration?.id,
            placementAudienceVersionId: draw.placementAudienceVersionId
        )), for: draw.profileId)
    }

    package static func logShowPaywall(_ paywall: AdaptyPaywall, viewConfiguration: AdaptyViewConfiguration) {
        trackEvent(.paywallShowed(.init(paywallVariationId: paywall.variationId, viewConfigurationId: viewConfiguration.id)))
    }
}

public extension Adapty {
    private static func _trackEvent(_ event: Event) async throws {
        do {
            let event = await Event.Unpacked(
                event: event,
                profileId: ProfileStorage.profileId,
                environment: Environment.instance
            )
            try await eventsManager.trackEvent(event)
        } catch {
            throw error.asAdaptyError ?? .trackEventFailed(unknownError: error)
        }
    }

    /// Call this method to notify Adapty SDK, that particular paywall was shown to user.
    ///
    /// Adapty helps you to measure the performance of the paywalls. We automatically collect all the metrics related to purchases except for paywall views. This is because only you know when the paywall was shown to a customer.
    /// Whenever you show a paywall to your user, call .logShowPaywall(paywall) to log the event, and it will be accumulated in the paywall metrics.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#paywall-analytics)
    ///
    /// - Parameters:
    ///   - paywall: A ``AdaptyPaywall`` object.
    ///  - Throws: An ``AdaptyError`` object
    nonisolated static func logShowPaywall(_ paywall: AdaptyPaywall) async throws {
        try await withActivatedSDK(methodName: .logShowPaywall) { _ in
            try await _trackEvent(.paywallShowed(.init(paywallVariationId: paywall.variationId, viewConfigurationId: nil)))
        }
    }

    /// Call this method to keep track of the user's steps while onboarding
    ///
    /// The onboarding stage is a very common situation in modern mobile apps. The quality of its implementation, content, and number of steps can have a rather significant influence on further user behavior, especially on his desire to become a subscriber or simply make some purchases.
    ///
    /// In order for you to be able to analyze user behavior at this critical stage without leaving Adapty, we have implemented the ability to send dedicated events every time a user visits yet another onboarding screen.
    ///
    /// - Parameters:
    ///   - name: Name of your onboarding.
    ///   - screenName: Readable name of a particular screen as part of onboarding.
    ///   - screenOrder: An unsigned integer value representing the order of this screen in your onboarding sequence (it must me greater than 0).
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func logShowOnboarding(name: String?, screenName: String?, screenOrder: UInt) async throws {
        try await logShowOnboarding(.init(
            name: name,
            screenName: screenName,
            screenOrder: screenOrder
        ))
    }

    nonisolated static func logShowOnboarding(_ params: AdaptyOnboardingScreenParameters) async throws {
        try await withActivatedSDK(methodName: .logShowOnboarding) { _ in

            guard params.screenOrder > 0 else {
                let error = AdaptyError.wrongParamOnboardingScreenOrder()
                Log.default.error(error.debugDescription)
                throw error
            }

            try await _trackEvent(.onboardingScreenShowed(params))
        }
    }

    nonisolated static func updateCollectingRefundDataConsent(_ consent: Bool) async throws {
        try await withActivatedSDK(methodName: .updateCollectingRefundDataConsent) { _ in
            try await _trackEvent(.сonsentToCollectingRefundData(.init(consent: consent)))
        }
    }

    nonisolated static func updateRefundPreference(_ refundPreference: AdaptyRefundPreference) async throws {
        try await withActivatedSDK(methodName: .updateRefundPreference) { _ in
            try await _trackEvent(.refundPreference(.init(refundPreference: refundPreference)))
        }
    }
}
