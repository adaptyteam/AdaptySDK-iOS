//
//  Backend.EventsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct EventsExecutor: BackendExecutor {
        let session: HTTPSession
    }

    func createEventsExecutor() -> EventsExecutor {
        EventsExecutor(
            session: HTTPSession(configuration: self, responseValidator: validator)
        )
    }
}
