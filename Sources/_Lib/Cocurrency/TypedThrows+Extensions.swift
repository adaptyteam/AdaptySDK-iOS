//
//  TypedThrows+Extensions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.07.2025.
//

struct CheckedContinuationWrapper<T, E: Error>: Sendable {
    private let wrapped: CheckedContinuation<Result<T, E>, Never>

    init(continuation: CheckedContinuation<Result<T, E>, Never>) {
        wrapped = continuation
    }

    func resume(with result: sending Result<T, E>) {
        wrapped.resume(with: .success(result))
    }

    func resume(with result: sending Result<T, some Error>) where E == any Error {
        resume(with: result.mapError { $0 as E })
    }

    func resume(returning value: sending T) {
        resume(with: .success(value))
    }

    func resume() where T == () {
        resume(with: .success(()))
    }

    func resume(throwing error: E) {
        resume(with: .failure(error))
    }

    func resume(throwing error: some Error) where E == any Error {
        resume(with: .failure(error as E))
    }
}

func withCheckedThrowingContinuation_<T: Sendable, E: Error>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (CheckedContinuationWrapper<T, E>) -> Void
) async throws(E) -> sending T {
    try await withCheckedContinuation(isolation: isolation, function: function) { (continuation: CheckedContinuation<Result<T, E>, Never>) in
        body(.init(continuation: continuation))
    }.get()
}

func withCheckedThrowingContinuation_<E: Error>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (CheckedContinuationWrapper<Void, E>) -> Void
) async throws(E) {
    try await withCheckedContinuation(isolation: isolation, function: function) { (continuation: CheckedContinuation<Result<Void, E>, Never>) in
        body(.init(continuation: continuation))
    }.get()
}
