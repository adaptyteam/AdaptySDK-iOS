//
//  Request.FlowViewDidAnswerLocalization.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct FlowViewDidAnswerLocalization: AdaptyPluginRequest {
        static let method = "flow_view_did_answer_localization"

        let eventId: String
        let result: String?

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
            case result
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.resolve(eventId: eventId, with: result)
            }
            return .success()
        }
    }
}
