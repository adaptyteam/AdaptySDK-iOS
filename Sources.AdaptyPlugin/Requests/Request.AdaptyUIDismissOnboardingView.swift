//
//  Request.AdaptyUIDismissOnboardingView.swift
//  AdaptyPlugin
//
//  Created by Alexey Goncharov on 5/16/25.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIDismissOnboardingView: AdaptyPluginRequest {
        static let method = "adapty_ui_dismiss_onboarding_view"

        let viewId: String
        let destroy: Bool

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case destroy
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            viewId = try container.decode(String.self, forKey: .viewId)
            destroy = try container.decodeIfPresent(Bool.self, forKey: .destroy) ?? false
        }

        @available(*, deprecated, message: "Onboarding Feature is deprecated.")
        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.dismissOnboardingView(
                viewId: viewId,
                destroy: destroy
            )
            return .success()
        }
    }
}
