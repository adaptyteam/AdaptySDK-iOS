//
//  Backend.EventsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct EventsExecutor: BackendExecutor {
        let manager: StateManager
        let session: HTTPSession
        let kind = AdaptyServerKind.main
    }

    func createEventsExecutor() -> EventsExecutor {
        EventsExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: defaultHTTPConfiguration, responseValidator: validator)
        )
    }
}
