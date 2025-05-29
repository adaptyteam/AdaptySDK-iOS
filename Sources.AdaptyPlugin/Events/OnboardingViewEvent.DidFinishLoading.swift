//
//  OnboardingViewEvent.OnboardingViewEvent.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct DidFinishLoading: AdaptyPluginEvent {
        let id = "onboarding_did_finish_loading"
        let view: AdaptyUI.OnboardingView
        let action: OnboardingsDidFinishLoadingAction

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case meta
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(view, forKey: .view)
            try container.encode(action.meta, forKey: .meta)
        }
    }
}
