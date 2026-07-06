//
//  HostRequestRegistry.swift
//  AdaptyPlugin
//

import Foundation

/// Correlates native-initiated host requests to their responses by `event_id`.
/// View-agnostic: keyed only by id. Cleanup = host response (`resolve`) or `flushCancelled` on teardown.
@MainActor
final class HostRequestRegistry {
    static let shared = HostRequestRegistry()

    init() {}

    private var counter: UInt64 = 0
    private var pending: [String: CheckedContinuation<(any Sendable)?, Never>] = [:]
    private var callbacks: [String: [String: @MainActor @Sendable () -> Void]] = [:]

    /// Generates a fresh correlation id.
    func nextEventId() -> String {
        counter &+= 1
        return "hr_\(counter)"
    }

    /// Emits a native→host request and suspends until the host responds (or the registry is flushed).
    /// Returns `nil` when cancelled/flushed. (Ask-once flavor.)
    func perform<Result>(
        _: Result.Type = Result.self,
        emit: (_ eventId: String) -> Void
    ) async -> Result? {
        let eventId = nextEventId()
        let raw: (any Sendable)? = await withCheckedContinuation { continuation in
            pending[eventId] = continuation
            emit(eventId)
        }
        return raw as? Result
    }

    /// Resolves a pending ask-once request. Unknown ids are ignored.
    func resolve(eventId: String, with value: (any Sendable)?) {
        pending.removeValue(forKey: eventId)?.resume(returning: value)
    }

    // MARK: - Lifecycle-callbacks flavor (e.g. ObserverMode purchase/restore)

    /// Stores a set of host-invoked lifecycle callbacks keyed by `event_id` (`signal` -> closure).
    func registerCallbacks(_ eventId: String, _ map: [String: @MainActor @Sendable () -> Void]) {
        callbacks[eventId] = map
    }

    /// Invokes one stored lifecycle callback. Unknown id/signal is ignored.
    func invokeCallback(eventId: String, signal: String) {
        callbacks[eventId]?[signal]?()
    }

    /// Drops a finished lifecycle request's callbacks.
    func releaseCallbacks(eventId: String) {
        callbacks.removeValue(forKey: eventId)
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
