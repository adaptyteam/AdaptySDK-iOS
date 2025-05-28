//
//  Request.AdaptyUICreateOnboardingViewForTest.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 23.05.2025.
//

import Adapty
import AdaptyUI
import Foundation

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
