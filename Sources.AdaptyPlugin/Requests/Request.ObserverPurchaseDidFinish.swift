//
//  Request.ObserverPurchaseDidFinish.swift
//  AdaptyPlugin
//

import Foundation

extension Request {
    struct ObserverPurchaseDidFinish: AdaptyPluginRequest {
        static let method = "observer_purchase_did_finish"

        let requestId: String

        enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
        }

        func execute() async throws -> AdaptyJsonData {
            await MainActor.run {
                HostRequestRegistry.shared.invokeCallback(requestId: requestId, signal: "purchase_finish")
                HostRequestRegistry.shared.releaseCallbacks(requestId: requestId)
            }
            return .success()
        }
    }
}
