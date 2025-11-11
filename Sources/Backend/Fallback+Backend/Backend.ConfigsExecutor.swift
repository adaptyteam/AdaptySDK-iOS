//
//  Backend.ConfigsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct ConfigsExecutor: BackendExecutor {
        let session: HTTPSession
        let baseURLFor: @BackendActor @Sendable (BackendRequest) async throws -> URL
    }

    func createConfigsExecutor() -> ConfigsExecutor {
        ConfigsExecutor(
            session: HTTPSession(configuration: defaultHTTPConfiguration),
            baseURLFor: networkManager.configsBaseUrl
        )
    }
}
