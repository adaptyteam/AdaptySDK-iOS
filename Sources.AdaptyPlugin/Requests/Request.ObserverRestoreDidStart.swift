//
//  Request.ObserverRestoreDidStart.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverRestoreDidStart: AdaptyPluginRequest {
        static let method = "observer_restore_did_start"

        let eventId: String

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(eventId: eventId, signal: "restore_start")
            }
            return .success()
        }
    }
}
