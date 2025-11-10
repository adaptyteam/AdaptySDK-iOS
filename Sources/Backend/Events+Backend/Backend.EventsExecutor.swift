//
//  Backend.EventsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct EventsExecutor: BackendExecutor {
        let networkManager: NetworkManager
        let session: HTTPSession
        let baseURLFor: @BackendActor @Sendable (HTTPEndpoint) async throws -> URL
        
    }

    func createEventsExecutor() -> EventsExecutor {
        EventsExecutor(
            networkManager: networkManager,
            session: HTTPSession(configuration: defaultHTTPConfiguration, responseValidator: validator),
            baseURLFor: networkManager.mainBaseUrl
        )
    }
}
