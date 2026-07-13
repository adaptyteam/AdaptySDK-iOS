//
//  Request.ObserverRestoreDidFinish.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverRestoreDidFinish: AdaptyPluginRequest {
        static let method = "observer_restore_did_finish"

        let eventId: String

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(eventId: eventId, signal: "restore_finish")
                HostRequestRegistry.shared.releaseCallbacks(eventId: eventId)
            }
            return .success()
        }
    }
}
