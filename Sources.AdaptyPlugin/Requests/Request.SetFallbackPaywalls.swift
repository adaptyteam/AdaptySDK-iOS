//
//  Request.SetFallbackPaywalls.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 19.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct SetFallbackPaywalls: AdaptyPluginRequest {
        static let method = "set_fallback_paywalls"
        let assetId: String

        private enum CodingKeys: String, CodingKey {
            case assetId = "asset_id"
        }

        func execute() async throws -> AdaptyJsonData {
            try await executeInMainActor()
        }

        @MainActor
        func executeInMainActor() async throws -> AdaptyJsonData {
            guard let assetIdToFileURL = Self.assetIdToFileURL else {
                throw AdaptyPluginInternalError.unknownRequest(SetFallbackPaywalls.method)
            }

            guard let url = assetIdToFileURL(assetId) else {
                throw AdaptyPluginInternalError.notExist("Asset \(assetId) not found")
            }

            try await Adapty.setFallbackPaywalls(fileURL: url)

            return .success()
        }

        @MainActor
        fileprivate static var assetIdToFileURL: (@MainActor (String) -> URL?)?
    }
}

public extension AdaptyPlugin {
    @MainActor
    static func reqister(setFallbackPaywallsRequests: @MainActor @escaping (String) -> URL?) {
        Request.SetFallbackPaywalls.assetIdToFileURL = setFallbackPaywallsRequests
        reqister(requests: [Request.SetFallbackPaywalls.self])
    }
}
