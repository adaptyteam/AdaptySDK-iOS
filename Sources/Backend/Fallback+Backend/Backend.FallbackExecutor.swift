//
//  Backend.FallbackExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct FallbackExecutor: DefaultAudienceExecutor {
        let manager: StateManager
        let session: HTTPSession
        let kind = AdaptyServerKind.fallback
    }

    func createFallbackExecutor() -> FallbackExecutor {
        FallbackExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: fallbackHTTPConfiguration)
        )
    }
}
