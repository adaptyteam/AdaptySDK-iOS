//
//  Request.SetFallback.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 19.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct SetFallback: AdaptyPluginRequest {
        static let method = "set_fallback"
        let path: String

        private enum CodingKeys: CodingKey {
            case path
        }

        func execute() async throws -> AdaptyJsonData {
            let fileURL = if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                URL(filePath: path)
            } else {
                URL(fileURLWithPath: path)
            }

            try await Adapty.setFallback(fileURL: fileURL)

            return .success()
        }
    }

    struct SetFallbackByAssetId: AdaptyPluginRequest {
        static let method = SetFallback.method
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
                throw AdaptyPluginInternalError.unknownRequest(SetFallback.method)
            }

            guard let url = assetIdToFileURL(assetId) else {
                throw AdaptyPluginInternalError.notExist("Asset \(assetId) not found")
            }

            try await Adapty.setFallback(fileURL: url)

            return .success()
        }

        @MainActor
        fileprivate static var assetIdToFileURL: (@MainActor (String) -> URL?)?
    }
}

public extension AdaptyPlugin {
    @MainActor
    static func register(setFallbackRequests: @MainActor @escaping (String) -> URL?) {
        Request.SetFallbackByAssetId.assetIdToFileURL = setFallbackRequests
        register(requests: [Request.SetFallbackByAssetId.self])
    }
}
