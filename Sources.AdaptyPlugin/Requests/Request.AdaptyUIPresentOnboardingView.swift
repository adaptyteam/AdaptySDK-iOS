//
//  File.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 5/16/25.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIPresentOnboardingView: AdaptyPluginRequest {
        static let method = "adapty_ui_present_onboarding_view"

        let viewId: String

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.presentOnboardingView(
                viewId: viewId
            )
            return .success()
        }
    }
}
