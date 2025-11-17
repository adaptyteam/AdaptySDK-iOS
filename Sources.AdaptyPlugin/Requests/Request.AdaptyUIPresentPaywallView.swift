//
//  Request.AdaptyUIPresentView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIPresentPaywallView: AdaptyPluginRequest {
        static let method = "adapty_ui_present_paywall_view"

        let viewId: String
        let presentationStyle: AdaptyUIViewPresentationStyle?

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case presentationStyle = "ios_presentation_style"
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.presentPaywallView(
                viewId: viewId,
                presentationStyle: presentationStyle
            )
            return .success()
        }
    }
}

