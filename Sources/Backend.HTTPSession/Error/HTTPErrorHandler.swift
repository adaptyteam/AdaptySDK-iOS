//
//  HTTPErrorHandler.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.08.2024
//

import Foundation

typealias HTTPErrorHandler = @Sendable (HTTPError) -> Void

actor HTTPErrorHandlerActor {
    let handler: HTTPErrorHandler

    init(handler: @escaping HTTPErrorHandler) {
        self.handler = handler
    }

    nonisolated func call(_ error: HTTPError) {
        Task.detached(priority: .utility) {
            self.handler(error)
        }
    }
}
