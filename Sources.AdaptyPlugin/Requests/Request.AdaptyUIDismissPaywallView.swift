//
//  Request.AdaptyUIDismissView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIDismissPaywallView: AdaptyPluginRequest {
        static let method = "adapty_ui_dismiss_paywall_view"

        let viewId: String
        let destroy: Bool

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case destroy
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.dismissPaywallView(
                viewId: viewId,
                destroy: destroy
            )
            return .success()
        }
    }
}
