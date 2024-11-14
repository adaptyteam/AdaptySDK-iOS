//
//  Request.AdaptyUIShowDialog.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIShowDialog: AdaptyPluginRequest {
        static let method = "adapty_ui_show_dialog"

        let viewId: String
        let configuration: AdaptyUI.DialogConfiguration

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case configuration
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await AdaptyUI.Plugin.showDialog(
                viewId: viewId,
                configuration: configuration
            ))
        }
    }
}
