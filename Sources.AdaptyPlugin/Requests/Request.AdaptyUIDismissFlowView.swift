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

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            viewId = try container.decode(String.self, forKey: .viewId)
            destroy = try container.decodeIfPresent(Bool.self, forKey: .destroy) ?? false
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
