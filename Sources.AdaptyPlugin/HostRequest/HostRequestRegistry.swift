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

    /// Emits a native→host request and suspends until the host responds (or the registry is flushed).
    /// Returns `nil` when cancelled/flushed.
    func perform<Result>(
        _: Result.Type = Result.self,
        emit: (_ requestId: String) -> Void
    ) async -> Result? {
        counter &+= 1
        let requestId = "hr_\(counter)"
        let raw: (any Sendable)? = await withCheckedContinuation { continuation in
            pending[requestId] = continuation
            emit(requestId)
        }
        return raw as? Result
    }

    /// Resolves a pending request. Unknown ids are ignored.
    func resolve(requestId: String, with value: (any Sendable)?) {
        pending.removeValue(forKey: requestId)?.resume(returning: value)
    }

    /// Resolves every pending request with `nil` and clears the registry.
    func flushCancelled() {
        let all = pending
        pending.removeAll()
        for continuation in all.values {
            continuation.resume(returning: nil)
        }
    }
}
