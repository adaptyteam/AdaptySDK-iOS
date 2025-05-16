//
//  Request.AdaptyUIPresentView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIPresentPaywallView: AdaptyPluginRequest {
        static let method = "adapty_ui_present_paywall_view"

        let viewId: String

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.presentPaywallView(
                viewId: viewId
            )
            return .success()
        }
    }
}

