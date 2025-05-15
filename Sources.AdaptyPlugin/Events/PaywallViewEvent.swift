//
//  PaywallViewEvent.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
enum PaywallViewEvent {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
enum OnboardingViewEvent {}

import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct DidFinishLoading: AdaptyPluginEvent {
        let id = "onboarding_did_finish_loading"
        let view: AdaptyUI.OnboardingView
//        let action: OnboardingsDidFinishLoadingAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnCloseAction: AdaptyPluginEvent {
        let id = "onboarding_on_close_action"
        let view: AdaptyUI.OnboardingView
//        let action: AdaptyOnboardingsCloseAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnPaywallAction: AdaptyPluginEvent {
        let id = "onboarding_on_paywall_action"
        let view: AdaptyUI.OnboardingView
//        let action: AdaptyOnboardingsOpenPaywallAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnCustomAction: AdaptyPluginEvent {
        let id = "onboarding_on_custom_action"
        let view: AdaptyUI.OnboardingView
//        let action: AdaptyOnboardingsCustomAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnStateUpdatedAction: AdaptyPluginEvent {
        let id = "onboarding_on_state_updated_action"
        let view: AdaptyUI.OnboardingView
//        let action: AdaptyOnboardingsStateUpdatedAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnAnalyticsEvent: AdaptyPluginEvent {
        let id = "onboarding_on_analytics_action"
        let view: AdaptyUI.OnboardingView
//        let action: AdaptyOnboardingsAnalyticsEvent

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct DidFailWithError: AdaptyPluginEvent {
        let id = "onboarding_did_fail_with_error"
        let view: AdaptyUI.OnboardingView
//        let error: AdaptyUIError

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}
