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
        let externalUrlsPresentation: AdaptyWebPresentation

        enum CodingKeys: String, CodingKey {
            case onboarding
            case externalUrlsPresentation = "external_urls_presentation"
        }

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
