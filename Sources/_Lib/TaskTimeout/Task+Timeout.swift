//
//  Task+Timeout.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

func withThrowingTimeout<T: Sendable>(
    _ timeout: TaskDuration,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    let task = Task(operation: operation)

    var timeoutTask: Task<Void, any Error>?

    if timeout < .never {
        guard timeout > .now else {
            task.cancel()
            throw TimeoutError(timeout.asTimeInterval)
        }

        timeoutTask = Task {
            defer { task.cancel() }
            try await Task.sleep(duration: timeout)
            throw TimeoutError(timeout.asTimeInterval)
        }
    }

    let result = await withTaskCancellationHandler {
        await task.result
    } onCancel: {
        task.cancel()
    }

    if let timeoutTask {
        timeoutTask.cancel()

        if case let .failure(error) = await timeoutTask.result, error is TimeoutError {
            throw error
        }
    }

    return try result.get()
}
