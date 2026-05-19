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

        @available(*, deprecated, message: "Onboarding Feature is deprecated.")
        let onboarding: AdaptyOnboarding
        let externalUrlsPresentation: AdaptyWebPresentation

        enum CodingKeys: String, CodingKey {
            case onboarding
            case externalUrlsPresentation = "external_urls_presentation"
        }

        @available(*, deprecated, message: "Onboarding Feature is deprecated.")
        func execute() async throws -> AdaptyJsonData {
            try .success(
                await AdaptyUI.Plugin.createOnboardingView(
                    onboarding: onboarding,
                    externalUrlsPresentation: externalUrlsPresentation
                )
            )
        }
    }
}
