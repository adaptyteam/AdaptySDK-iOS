//
//  Request.ObserverRestoreDidStart.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverRestoreDidStart: AdaptyPluginRequest {
        static let method = "observer_restore_did_start"

        let requestId: String

        enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(requestId: requestId, signal: "restore_start")
            }
            return .success()
        }
    }
}
