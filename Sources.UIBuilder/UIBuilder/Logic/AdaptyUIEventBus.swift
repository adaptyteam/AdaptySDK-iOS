//
//  AdaptyUIEventBus.swift
//  AdaptyUIBuilder
//
//  Created on 09.04.2026.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
final class AdaptyUIEventBus: ObservableObject {
    struct Event: Equatable {
        let sequence: UInt
        let eventId: VC.EventHandler.EventId
        let transitionId: String?
        let screenInstanceId: String?

        var isCustom: Bool {
            if case .custom = eventId { return true }
            return false
        }
    }

    private var nextSequence: UInt = 1

    /// Sticky buffer — events published before subscribers exist.
    /// Elements consume pending events on mount.
    private(set) var pendingEvents: [Event] = []

    /// How many custom events the buffer keeps. A custom event must stay
    /// buffered until mounted subscribers react to the revision change, and
    /// several publishes can land before SwiftUI processes one
    /// (`SDK.sendEvents` with a list of events), so nothing evicts it on the
    /// next publish. Late-mounting subscribers skip it by their cursor
    /// (see `lastSequence`), so keeping it longer replays nothing.
    // ponytail: a fixed cap; a burst of more custom events than this between
    // two SwiftUI updates loses the oldest ones.
    static let customEventsLimit = 1024

    /// Incremented on each publish. Elements observe this via onChange.
    @Published private(set) var revision: UInt = 0

    /// Sequence of the latest published event, `0` before the first one.
    /// A subscriber that arms (first mount, section re-arm) moves its cursor
    /// here, so custom events published before it armed are never delivered
    /// to it, however long they stay buffered.
    var lastSequence: UInt { nextSequence - 1 }

    func publish(eventId: VC.EventHandler.EventId, transitionId: String?, screenInstanceId: String?) {
        let event = Event(
            sequence: nextSequence,
            eventId: eventId,
            transitionId: transitionId,
            screenInstanceId: screenInstanceId
        )
        nextSequence += 1
        pendingEvents.append(event)
        Log.ui.verbose("#EventBus# publish \(eventId) seq=\(event.sequence) screen=\(screenInstanceId ?? "nil")")
        if event.isCustom,
           pendingEvents.lazy.filter(\.isCustom).count > Self.customEventsLimit,
           let oldest = pendingEvents.firstIndex(where: \.isCustom)
        {
            let dropped = pendingEvents.remove(at: oldest)
            Log.ui.warn("#EventBus# drop \(dropped.eventId) seq=\(dropped.sequence): more than \(Self.customEventsLimit) custom events buffered")
        }
        incrementFireCount(screenInstanceId: screenInstanceId, eventId: eventId)
        revision &+= 1
    }

    /// Returns pending events matching the given context, newer than afterSequence.
    ///
    /// - Parameter includeCustom: when `false`, transient `.custom` events are
    ///   filtered out. Consumers pass `false` on their "arming" paths (first
    ///   mount / section-index re-arm), where only sticky lifecycle events
    ///   should be replayed. A `.custom` event still buffered at that point was
    ///   published while a different subtree was mounted and must not be
    ///   replayed to one that mounts afterward; such a caller also moves its
    ///   cursor to `lastSequence`, so the live path skips that event too.
    ///   See SDK-1088 (bottom-sheet overlay re-show).
    func consumePending(
        afterSequence: UInt,
        screenInstanceId: String?,
        currentTopScreenInstanceId: String?,
        includeCustom: Bool = true
    ) -> [Event] {
        pendingEvents.filter { event in
            guard event.sequence > afterSequence else { return false }
            if !includeCustom, case .custom = event.eventId { return false }
            return matchesScope(event, screenInstanceId: screenInstanceId, currentTopScreenInstanceId: currentTopScreenInstanceId)
        }
    }

    // MARK: - Fire counts for first/notFirst filter

    /// Tracks how many times each event has fired per screen instance.
    /// Key: screenInstanceId (empty string for navigator-level).
    private var eventFireCounts: [String: [VC.EventHandler.EventId: Int]] = [:]

    func fireCount(screenInstanceId: String?, eventId: VC.EventHandler.EventId) -> Int {
        eventFireCounts[screenInstanceId ?? ""]?[eventId] ?? 0
    }

    func incrementFireCount(screenInstanceId: String?, eventId: VC.EventHandler.EventId) {
        let key = screenInstanceId ?? ""
        eventFireCounts[key, default: [:]][eventId, default: 0] += 1
    }

    // MARK: - Pending event cleanup

    /// Clear events that are no longer relevant.
    func clearPending(for screenInstanceId: String?) {
        if let screenInstanceId {
            pendingEvents.removeAll { $0.screenInstanceId == screenInstanceId }
        } else {
            pendingEvents.removeAll()
        }
    }

    private func matchesScope(
        _ event: Event,
        screenInstanceId: String?,
        currentTopScreenInstanceId: String?
    ) -> Bool {
        switch event.eventId {
        case .onWillAppear, .onDidAppear, .onWillDisappear, .onDidDisappear:
            if let screenInstanceId {
                return event.screenInstanceId == screenInstanceId
            }
            return event.screenInstanceId == nil

        case .custom:
            if let eventTargetId = event.screenInstanceId {
                if let screenInstanceId {
                    return eventTargetId == screenInstanceId
                } else {
                    return eventTargetId == currentTopScreenInstanceId
                }
            }
            return true
        }
    }
}

#endif
