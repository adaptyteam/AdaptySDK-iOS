//
//  TypedThrows+Extensions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.07.2025.
//

struct CheckedContinuationWrapper<T, E>: Sendable where E: Error {
    private let wrapped: CheckedContinuation<Result<T, E>, Never>

    init(continuation: CheckedContinuation<Result<T, E>, Never>) {
        self.wrapped = continuation
    }

    func resume(with result: sending Result<T, E>) {
        wrapped.resume(with: .success(result))
    }

    func resume<Er>(with result: sending Result<T, Er>) where E == any Error, Er: Error {
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

    func resume<Er>(throwing error: Er) where E == any Error, Er: Error {
        resume(with: .failure(error as E))
    }
}

func withCheckedThrowingContinuation_<T: Sendable, E>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (CheckedContinuationWrapper<T, E>) -> Void
) async throws(E) -> sending T where E: Error {
    try await withCheckedContinuation(isolation: isolation, function: function) { (continuation: CheckedContinuation<Result<T, E>, Never>) in
        body(.init(continuation: continuation))
    }.get()
}

func withCheckedThrowingContinuation_<E>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (CheckedContinuationWrapper<Void, E>) -> Void
) async throws(E) where E: Error {
    try await withCheckedContinuation(isolation: isolation, function: function) { (continuation: CheckedContinuation<Result<Void, E>, Never>) in
        body(.init(continuation: continuation))
    }.get()
}
