//
//  Backend.DefaultExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct DefaultExecutor: BackendExecutor {
        let session: HTTPSession
        let baseURLFor: @BackendActor @Sendable (BackendRequest) async throws -> URL
    }

    func createDefaultExecutor() -> DefaultExecutor {
        DefaultExecutor(
            session: HTTPSession(configuration: defaultHTTPConfiguration, responseValidator: validator),
            baseURLFor: networkManager.mainBaseUrl
        )
    }
}
