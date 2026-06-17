//
//  Request.ObserverRestoreDidFinish.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverRestoreDidFinish: AdaptyPluginRequest {
        static let method = "observer_restore_did_finish"

        let requestId: String

        enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(requestId: requestId, signal: "restore_finish")
                HostRequestRegistry.shared.releaseCallbacks(requestId: requestId)
            }
            return .success()
        }
    }
}
