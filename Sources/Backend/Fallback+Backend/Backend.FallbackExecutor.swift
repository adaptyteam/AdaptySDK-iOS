//
//  Backend.FallbackExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct FallbackExecutor: BackendExecutor {
        let session: HTTPSession
        let baseURLFor: @BackendActor @Sendable (HTTPEndpoint) async throws -> URL
    }

    func createFallbackExecutor() -> FallbackExecutor {
        FallbackExecutor(
            session: HTTPSession(configuration: fallbackHTTPConfiguration),
            baseURLFor: networkManager.fallbackBaseUrl
        )
    }
}
