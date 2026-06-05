//
//  Request.DidRequestPermissionResponse.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct DidRequestPermissionResponse: AdaptyPluginRequest {
        static let method = "did_request_permission_response"

        let requestId: String
        let status: PermissionResolution.Status
        let detail: String?

        enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case status
            case detail
        }

        func execute() async throws -> AdaptyJsonData {
            let resolution = PermissionResolution(status: status, detail: detail)
            await MainActor.run {
                HostRequestRegistry.shared.resolve(requestId: requestId, with: resolution)
            }
            return .success()
        }
    }
}
