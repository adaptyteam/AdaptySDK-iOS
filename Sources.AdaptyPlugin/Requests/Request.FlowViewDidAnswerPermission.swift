//
//  Request.FlowViewDidAnswerPermission.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct FlowViewDidAnswerPermission: AdaptyPluginRequest {
        static let method = "flow_view_did_answer_permission"

        let eventId: String
        let status: PermissionResolution.Status
        let detail: String?

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
            case status
            case detail
        }

        func execute() async throws -> AdaptyJsonData {
            let resolution = PermissionResolution(status: status, detail: detail)
            await MainActor.run {
                HostRequestRegistry.shared.resolve(eventId: eventId, with: resolution)
            }
            return .success()
        }
    }
}
