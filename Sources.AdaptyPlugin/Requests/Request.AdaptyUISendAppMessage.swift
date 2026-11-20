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
        let messageId: String
        let payload: [String: any Sendable]

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case messageId = "message_id"
            case payload
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            viewId = try container.decode(String.self, forKey: .viewId)
            messageId = try container.decode(String.self, forKey: .messageId)
            payload = try container.decodeDictionary(forKey: .payload)
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.sendAppMessage(viewId: viewId, messageId: messageId, payload: payload)
            return .success()
        }
    }
}
