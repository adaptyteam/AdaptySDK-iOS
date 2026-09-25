//
//  Request.AdaptyUIDestroyFlowView.swift
//  AdaptyPlugin
//
//  Created by Stanislav Mayorov on 16.09.2026.
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIDestroyFlowView: AdaptyPluginRequest {
        static let method = "adapty_ui_destroy_flow_view"

        let viewId: String

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.destroyFlowView(viewId: viewId)
            return .success()
        }
    }
}
