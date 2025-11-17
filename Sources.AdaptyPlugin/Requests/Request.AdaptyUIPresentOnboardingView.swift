//
//  File.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 5/16/25.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIPresentOnboardingView: AdaptyPluginRequest {
        static let method = "adapty_ui_present_onboarding_view"

        let viewId: String
        let presentationStyle: AdaptyUIViewPresentationStyle?

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case presentationStyle = "ios_presentation_style"
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.presentOnboardingView(
                viewId: viewId,
                presentationStyle: presentationStyle
            )
            return .success()
        }
    }
}
