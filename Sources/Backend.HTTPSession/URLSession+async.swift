//
//  URLSession+async.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.08.2024
//

import Foundation

struct URLErrorWithMetrics: Error {
    let error: Error
    let metrics: URLSessionTaskMetrics?
}

extension URLSession {
    func data(with request: URLRequest, sessionState: HTTPSessionState) async throws -> (Data, HTTPURLResponse, URLSessionTaskMetrics?) {
        let taskState = HTTPTaskState()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    let task = self.dataTask(with: request) { data, response, error in
                        Task {
                            let metrics = await taskState.metrics

                            if let data, let response = response as? HTTPURLResponse {
                                continuation.resume(returning: (data, response, metrics))
                            } else {
                                let error = error ?? URLError(.badServerResponse)
                                continuation.resume(throwing: URLErrorWithMetrics(error: error, metrics: metrics))
                            }

                            if let taskIdentifier = await taskState.taskIdentifier {
                                await sessionState.removeTaskState(byTaskIdentifier: taskIdentifier)
                            }
                        }
                    }

                    await sessionState.set(taskState: taskState, forTaskIdentifier: task.taskIdentifier)
                    await taskState.start(task)
                }
            }
        }
        onCancel: {
            Task { await taskState.cancel() }
        }
    }
}
