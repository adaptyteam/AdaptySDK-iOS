//
//  Task+Timeout.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

func withThrowingTimeout<T: Sendable>(
    _ timeout: AdaptyDuration,
    operation: sending @escaping @isolated(any) () async throws -> T,
    isolation _: isolated (any Actor)? = #isolation
) async throws -> T {
    let task = Task(operation: operation)

    guard timeout > .zero else {
        task.cancel()
        throw TimeoutError(timeout)
    }

    let timeoutTask = Task {
        defer { task.cancel() }
        try await Task.sleep(duration: timeout)
        throw TimeoutError(timeout)
    }

    let result = await withTaskCancellationHandler {
        await task.result
    } onCancel: {
        task.cancel()
    }

    timeoutTask.cancel()

    if case let .failure(error) = await timeoutTask.result, error is TimeoutError {
        throw error
    }

    return try result.get()
}
