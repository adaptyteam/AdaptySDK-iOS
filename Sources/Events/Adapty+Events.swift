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

    @EventsManagerActor
    static func trackEvent(
        _ event: Event,
        for userId: AdaptyUserId? = nil,
        date: Date = Date()
    ) async throws(AdaptyError) {
        let userId =
            if let userId {
                userId
            } else {
                await ProfileStorage.userId
            }

        let event = await Event.Unpacked(
            event: event,
            userId: userId,
            environment: Environment.instance,
            createdAt: date
        )
        do {
            try eventsManager.trackEvent(event)
        } catch {
            throw error.asAdaptyError
        }
    }

    package nonisolated static func trackSystemEvent(
        _ params: AdaptySystemEventParameters,
        for userId: AdaptyUserId? = nil,
        date: Date = Date()
    ) {
        Task.detached(priority: .utility) {
            try? await trackEvent(
                .system(params),
                for: userId,
                date: date
            )
        }
    }

    nonisolated static func trackEventIfNeed(
        _ chosen: AdaptyPlacementChosen<some PlacementContent>,
        date: Date = Date()
    ) {
        guard case let .draw(draw) = chosen else {
            return
        }
        let event: Event
        if let flow = draw.content as? AdaptyFlow {
            event = .flowVariationAssigned(.init(
                variationId: flow.variationId,
                viewConfigurationId: flow.viewConfigurationId,
                placementAudienceVersionId: draw.placementAudienceVersionId
            ))

            Log.crossAB.verbose("-> trackEvent flowVariationAssigned variationId = \(flow.variationId)")

        } else if let onboarding = draw.content as? AdaptyOnboarding {
            event = .onboardingVariationAssigned(.init(
                variationId: onboarding.variationId,
                placementAudienceVersionId: draw.placementAudienceVersionId
            ))

            Log.crossAB.verbose("-> trackEvent onboardingVariationAssigned variationId = \(onboarding.variationId)")

        } else {
            Log.crossAB.warn("-> Warnning: unknown content type for variationAssigned event, variationId = \(draw.content.variationId)")
            return
        }

        Task.detached(priority: .utility) {
            try? await trackEvent(
                event,
                for: draw.userId,
                date: date
            )
        }
    }
}

public extension Adapty {
    /// Call this method to notify Adapty SDK that a particular flow was shown to the user.
    ///
    /// Adapty helps you measure the performance of your flows. We automatically collect all the metrics related to purchases except for flow views. This is because only you know when the flow was shown to a customer.
    /// Whenever you show a flow to your user, call `.logShowFlow(flow)` to log the event, and it will be accumulated in the flow metrics.
    ///
    /// Read more in the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#paywall-analytics).
    ///
    /// - Parameters:
    ///   - paywall: An ``AdaptyFlow`` object.
    /// - Throws: An ``AdaptyError`` object.
    nonisolated static func logShowFlow(_ flow: AdaptyFlow) async throws(AdaptyError) {
        let now = Date()
        try await withActivatedSDK(methodName: .logShowFlow) { _ throws(AdaptyError) in
            try await trackEvent(
                .flowShowed(.init(
                    variationId: flow.variationId
                )),
                date: now
            )
        }
    }

    /// Call this method to update the current user's refund data consent.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/refund-saver#obtain-user-consent)
    ///
    /// - Parameters:
    ///   - consent: `Bool` value whether user gave the consent or not.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func updateCollectingRefundDataConsent(_ consent: Bool) async throws(AdaptyError) {
        let now = Date()
        try await withActivatedSDK(methodName: .updateCollectingRefundDataConsent) { _ throws(AdaptyError) in
            try await trackEvent(
                .сonsentToCollectingRefundData(.init(consent: consent)),
                date: now
            )
        }
    }

    /// Call this method to set the refund preference individually for current user.
    ///
    /// Read more on the [Adapty Documentation](https://adapty.io/docs/refund-saver#set-refund-behavior-for-a-specific-user-in-the-dashboard)
    ///
    /// - Parameters:
    ///   - refundPreference: ``AdaptyRefundPreference`` value.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func updateRefundPreference(_ refundPreference: AdaptyRefundPreference) async throws(AdaptyError) {
        let now = Date()
        try await withActivatedSDK(methodName: .updateRefundPreference) { _ throws(AdaptyError) in
            try await trackEvent(
                .refundPreference(.init(refundPreference: refundPreference)),
                date: now
            )
        }
    }
}
