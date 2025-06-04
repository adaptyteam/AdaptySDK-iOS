//
//  OnboardingViewEvent.OnCustomAction .swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct OnCustomAction: AdaptyPluginEvent {
        let id = "onboarding_on_custom_action"
        let view: AdaptyUI.OnboardingView
        let action: AdaptyOnboardingsCustomAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case meta
            case actionId = "action_id"
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(view, forKey: .view)
            try container.encode(action.meta, forKey: .meta)
            try container.encode(action.actionId, forKey: .actionId)
        }
    }
}
