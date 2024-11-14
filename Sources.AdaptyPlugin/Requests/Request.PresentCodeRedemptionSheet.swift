//
//  Request.PresentCodeRedemptionSheet.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct PresentCodeRedemptionSheet: AdaptyPluginRequest {
        static let method = "present_code_redemption_sheet"

        func execute() async throws -> AdaptyJsonData {
            Adapty.presentCodeRedemptionSheet()
            return .success()
        }
    }
}
