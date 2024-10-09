//
//  Task+Timeout.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

package func withThrowingTimeout<T: Sendable>(
    seconds: TimeInterval,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    let task = Task(operation: operation)

    var timeoutTask: Task<Void, any Error>?

    if seconds.isNormal {
        guard seconds > 0 else {
            task.cancel()
            throw TimeoutError(seconds)
        }

        timeoutTask = Task {
            defer { task.cancel() }
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError(seconds)
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

package extension Task where Failure == Error {
    static func detached(
        priority: TaskPriority? = nil,
        timeout: TimeInterval,
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task<Success, Failure> {
        detached(priority: priority) {
            try await withThrowingTimeout(seconds: timeout, operation: operation)
        }
    }

    init(
        priority: TaskPriority? = nil,
        timeout: TimeInterval,
        operation: @escaping @Sendable () async throws -> Success
    ) {
        self.init(priority: priority) {
            try await withThrowingTimeout(seconds: timeout, operation: operation)
        }
    }
}

package extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            try await Task.sleep(for: .seconds(seconds))
        } else {
            try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
        }
    }
}
