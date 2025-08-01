//
//  Task+Cancellation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.11.2024.
//

import Foundation

func withTaskCancellationWithError<T: Sendable>(
    _ onCancelError: any Error,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    let task = TaskReference()
    let once = OncePerformer()
    return try await withTaskCancellationHandler(operation: { @PerformerActor in
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            guard !Task.isCancelled else {
                continuation.resume(throwing: onCancelError)
                return
            }

            let _task = Task {
                await withTaskCancellationHandler {
                    do {
                        let taskResult = try await operation()
                        once.perform { continuation.resume(returning: taskResult) }
                    } catch {
                        once.perform { continuation.resume(throwing: error) }
                    }
                } onCancel: {
                    Task { @PerformerActor in
                        once.perform { continuation.resume(throwing: onCancelError) }
                    }
                }
            }

            task.set(_task)
        }
    }, onCancel: {
        Task { @PerformerActor in
            task.cancel()
        }
    })
}

@globalActor
private actor PerformerActor {
    static let shared = PerformerActor()
}

private final class TaskReference: Sendable {
    typealias Wrapped = Task<Void, Never>

    @PerformerActor
    var wrapped: Wrapped?

    @PerformerActor
    func set(_ task: Wrapped?) {
        wrapped = task
    }

    @PerformerActor
    func cancel() {
        wrapped?.cancel()
    }
}

private final class OncePerformer: Sendable {
    @PerformerActor
    var performed = false

    @PerformerActor
    func perform(_ operation: @Sendable () -> Void) {
        guard !performed else { return }
        defer { performed = true }
        operation()
    }
}
