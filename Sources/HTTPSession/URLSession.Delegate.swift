//
//  URLSession.Delegate.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.08.2024
//

import Foundation

extension URLSession {
    final class Delegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, Sendable {
        let sessionState: HTTPSessionState
        let configuration: HTTPConfiguration

        init(sessionState: HTTPSessionState, configuration: HTTPConfiguration) {
            self.sessionState = sessionState
            self.configuration = configuration
        }

        func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
            Task {
                guard let taskState = await sessionState.taskState(byTaskIdentifier: task.taskIdentifier) else { return }
                await taskState.set(metrics: metrics)
            }
        }
    }
}
