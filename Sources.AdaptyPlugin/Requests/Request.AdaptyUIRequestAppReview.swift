//
//  Request.AdaptyUIRequestAppReview.swift
//  AdaptyPlugin
//

import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUIRequestAppReview: AdaptyPluginRequest {
        static let method = "adapty_ui_request_app_review"

        func execute() async throws -> AdaptyJsonData {
            await AdaptyUI.Plugin.requestAppReview()
            return .success()
        }
    }
}
