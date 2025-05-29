//
//  OnboardingViewEvent.OnAnalyticsAction.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnAnalyticsAction: AdaptyPluginEvent {
        let id = "onboarding_on_analytics_action"
        let view: AdaptyUI.OnboardingView
        let event: AdaptyOnboardingsAnalyticsEvent

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case meta
            case event
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(view, forKey: .view)
            try container.encode(event.meta, forKey: .meta)
            try container.encode(event, forKey: .event)
        }
    }
}
