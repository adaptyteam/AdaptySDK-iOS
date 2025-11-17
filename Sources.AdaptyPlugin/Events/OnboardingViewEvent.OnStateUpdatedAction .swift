//
//  OnboardingViewEvent.OnStateUpdatedAction .swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI

extension OnboardingViewEvent {
    struct OnStateUpdatedAction: AdaptyPluginEvent {
        let id = "onboarding_on_state_updated_action"
        let view: AdaptyUI.OnboardingView
        let action: AdaptyOnboardingsStateUpdatedAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case meta
            case action
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(view, forKey: .view)
            try container.encode(action.meta, forKey: .meta)
            try container.encode(action, forKey: .action)
        }
    }
}
