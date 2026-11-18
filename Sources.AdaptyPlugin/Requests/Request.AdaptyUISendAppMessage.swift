//
//  Request.AdaptyUISendAppMessage.swift
//  AdaptyPlugin
//

import AdaptyCodable
import AdaptyUI
import Foundation

extension Request {
    struct AdaptyUISendAppMessage: AdaptyPluginRequest {
        static let method = "adapty_ui_send_app_message"

        let viewId: String
        let payload: [String: any Sendable]

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case payload
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            viewId = try container.decode(String.self, forKey: .viewId)
            payload = try container.decodeDictionary(forKey: .payload)
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.sendAppMessage(viewId: viewId, payload: payload)
            return .success()
        }
    }
}
