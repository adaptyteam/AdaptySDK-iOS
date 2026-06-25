//
//  Request.ObserverPurchaseDidStart.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverPurchaseDidStart: AdaptyPluginRequest {
        static let method = "observer_purchase_did_start"

        let eventId: String

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(eventId: eventId, signal: "purchase_start")
            }
            return .success()
        }
    }
}
