//
//  Request.ObserverPurchaseDidStart.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverPurchaseDidStart: AdaptyPluginRequest {
        static let method = "observer_purchase_did_start"

        let requestId: String

        enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(requestId: requestId, signal: "purchase_start")
            }
            return .success()
        }
    }
}
