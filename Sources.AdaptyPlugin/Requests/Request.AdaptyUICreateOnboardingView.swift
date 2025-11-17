//
//  Request.AdaptyUICreateOnboardingView.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 5/16/25.
//

import Adapty
import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUICreateOnboardingView: AdaptyPluginRequest {
        static let method = "adapty_ui_create_onboarding_view"

        let onboarding: AdaptyOnboarding

        enum CodingKeys: String, CodingKey {
            case onboarding
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(
                await AdaptyUI.Plugin.createOnboardingView(
                    onboarding: onboarding
                )
            )
        }
    }
}
