//
//  OnboardingViewEvent.DidFailWithError .swift
//  Adaptyplugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension OnboardingViewEvent {
    struct DidFailWithError: AdaptyPluginEvent {
        let id = "onboarding_did_fail_with_error"
        let view: AdaptyUI.OnboardingView
        let error: AdaptyUIError

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case error
        }
    }
}
