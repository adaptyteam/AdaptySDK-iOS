//
//  File.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 5/16/25.
//

import Adapty
import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

// TODO: Remove
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUICreateOnboardingViewForTest: AdaptyPluginRequest {
        static let method = "adapty_ui_create_onboarding_view_for_test"

        let placementId: String

        enum CodingKeys: String, CodingKey {
            case placementId = "placement_id"
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(
                await AdaptyUI.Plugin.createOnboardingViewForTest(
                    placementId: placementId
                )
            )
        }
    }
}
