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
    }

    private var nextSequence: UInt = 1

    /// Sticky buffer — events published before subscribers exist.
    /// Elements consume pending events on mount.
    private(set) var pendingEvents: [Event] = []

    /// Incremented on each publish. Elements observe this via onChange.
    @Published private(set) var revision: UInt = 0

    func publish(eventId: VC.EventHandler.EventId, transitionId: String?, screenInstanceId: String?) {
        let event = Event(
            sequence: nextSequence,
            eventId: eventId,
            transitionId: transitionId,
            screenInstanceId: screenInstanceId
        )
        nextSequence += 1
        pendingEvents.append(event)
        incrementFireCount(screenInstanceId: screenInstanceId, eventId: eventId)
        revision &+= 1
    }

    /// Returns pending events matching the given context, newer than afterSequence.
    func consumePending(
        afterSequence: UInt,
        screenInstanceId: String?,
        currentTopScreenInstanceId: String?
    ) -> [Event] {
        pendingEvents.filter { event in
            event.sequence > afterSequence
                && matchesScope(event, screenInstanceId: screenInstanceId, currentTopScreenInstanceId: currentTopScreenInstanceId)
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
