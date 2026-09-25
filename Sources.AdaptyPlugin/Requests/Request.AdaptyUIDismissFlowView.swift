//
//  Request.AdaptyUIDismissFlowView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIDismissFlowView: AdaptyPluginRequest {
        static let method = "adapty_ui_dismiss_flow_view"

        let viewId: String
        let destroy: Bool

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case destroy
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.dismissFlowView(
                viewId: viewId,
                destroy: destroy
            )
            return .success()
        }
    }
}
