//
//  Adapty+Events.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Adapty {
    static var eventsManager = EventsManager(profileStorage: UserDefaults.standard)

    fileprivate static func trackEvent(_ eventType: EventType, _ completion: AdaptyErrorCompletion? = nil) {
        async(completion) { manager, completion in
            Adapty.eventsManager.trackEvent(Event(type: eventType, profileId: manager.profileStorage.profileId)) { error in
                completion(error?.asAdaptyError)
            }
        }
    }

    static func logAppOpened(completion: AdaptyErrorCompletion? = nil) {
        trackEvent(.appOpened, completion)
    }

    static func logSystemEvent(_ params: AdaptySystemEventParameters) {
        eventsManager.trackEvent(Event(type: .system(params), profileId: profileIdentifierStorage.profileId), completion: { _ in })
    }

    /// Call this method to notify Adapty SDK, that particular paywall was shown to user.
    ///
    /// Adapty helps you to measure the performance of the paywalls. We automatically collect all the metrics related to purchases except for paywall views. This is because only you know when the paywall was shown to a customer.
    /// Whenever you show a paywall to your user, call .logShowPaywall(paywall) to log the event, and it will be accumulated in the paywall metrics.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-displaying-products#paywall-analytics)
    ///
    /// - Parameters:
    ///   - paywall: A `AdaptyPaywall` object.
    ///   - completion: Result callback.
    public static func logShowPaywall(_ paywall: AdaptyPaywall, _ completion: AdaptyErrorCompletion? = nil) {
        trackEvent(.paywallShowed(AdaptyPaywallShowedParameters(paywallVariationId: paywall.variationId, viewConfigurationId: nil)), completion)
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
    ///   - completion: Result callback.
    public static func logShowOnboarding(name: String?, screenName: String?, screenOrder: UInt, _ completion: AdaptyErrorCompletion? = nil) {
        let params = AdaptyOnboardingScreenParameters(
            name: name,
            screenName: screenName,
            screenOrder: screenOrder
        )
        logShowOnboarding(params, completion)
    }

    public static func logShowOnboarding(_ params: AdaptyOnboardingScreenParameters, _ completion: AdaptyErrorCompletion? = nil) {
        guard params.screenOrder > 0 else {
            let error = AdaptyError.wrongParamOnboardingScreenOrder()
            Log.error(error.debugDescription)
            completion?(error)
            return
        }

        trackEvent(.onboardingScreenShowed(params), completion)
    }
}

extension AdaptyUI {
    public static func logShowPaywall(_ paywall: AdaptyPaywall, viewConfiguration: AdaptyUI.LocalizedViewConfiguration, _ completion: AdaptyErrorCompletion? = nil) {
        Adapty.trackEvent(.paywallShowed(AdaptyPaywallShowedParameters(paywallVariationId: paywall.variationId, viewConfigurationId: viewConfiguration.id)), completion)
    }
}
