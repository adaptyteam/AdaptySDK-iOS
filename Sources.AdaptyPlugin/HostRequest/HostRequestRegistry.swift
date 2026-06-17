//
//  HostRequestRegistry.swift
//  AdaptyPlugin
//

import Foundation

/// Correlates native-initiated host requests to their responses by `request_id`.
/// View-agnostic: keyed only by id. Cleanup = host response (`resolve`) or `flushCancelled` on teardown.
@MainActor
final class HostRequestRegistry {
    static let shared = HostRequestRegistry()

    init() {}

    private var counter: UInt64 = 0
    private var pending: [String: CheckedContinuation<(any Sendable)?, Never>] = [:]
    private var callbacks: [String: [String: @MainActor @Sendable () -> Void]] = [:]

    /// Generates a fresh correlation id.
    func nextRequestId() -> String {
        counter &+= 1
        return "hr_\(counter)"
    }

    /// Emits a native→host request and suspends until the host responds (or the registry is flushed).
    /// Returns `nil` when cancelled/flushed. (Ask-once flavor.)
    func perform<Result>(
        _: Result.Type = Result.self,
        emit: (_ requestId: String) -> Void
    ) async -> Result? {
        let requestId = nextRequestId()
        let raw: (any Sendable)? = await withCheckedContinuation { continuation in
            pending[requestId] = continuation
            emit(requestId)
        }
        return raw as? Result
    }

    /// Resolves a pending ask-once request. Unknown ids are ignored.
    func resolve(requestId: String, with value: (any Sendable)?) {
        pending.removeValue(forKey: requestId)?.resume(returning: value)
    }

    // MARK: - Lifecycle-callbacks flavor (e.g. ObserverMode purchase/restore)

    /// Stores a set of host-invoked lifecycle callbacks keyed by `request_id` (`signal` -> closure).
    func registerCallbacks(_ requestId: String, _ map: [String: @MainActor @Sendable () -> Void]) {
        callbacks[requestId] = map
    }

    /// Invokes one stored lifecycle callback. Unknown id/signal is ignored.
    func invokeCallback(requestId: String, signal: String) {
        callbacks[requestId]?[signal]?()
    }

    /// Drops a finished lifecycle request's callbacks.
    func releaseCallbacks(requestId: String) {
        callbacks.removeValue(forKey: requestId)
    }

    /// Resolves every pending ask-once request with `nil` and clears all lifecycle callbacks.
    func flushCancelled() {
        let all = pending
        pending.removeAll()
        callbacks.removeAll()
        for continuation in all.values {
            continuation.resume(returning: nil)
        }
    }
}
