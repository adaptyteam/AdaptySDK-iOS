//
//  AdaptyUIEventBusTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

@testable import AdaptyUIBuilder
import Testing

@Suite("AdaptyUIEventBus")
@MainActor
struct AdaptyUIEventBusTests {
    private func publishCustom(_ bus: AdaptyUIEventBus, _ id: String) {
        bus.publish(eventId: .custom(id), transitionId: nil, screenInstanceId: nil)
    }

    private func customIds(_ events: [AdaptyUIEventBus.Event]) -> [String] {
        events.compactMap {
            if case let .custom(id) = $0.eventId { return id }
            return nil
        }
    }

    /// `SDK.sendEvents({ events: ['ev_03', 'ev_03b'] })` publishes twice before
    /// SwiftUI reacts to the revision change; a mounted subscriber gets both.
    @Test("Custom events published back to back all reach a mounted subscriber")
    func customEventsInOneBurstAreAllDelivered() {
        let bus = AdaptyUIEventBus()

        publishCustom(bus, "ev_03")
        publishCustom(bus, "ev_03b")

        let delivered = bus.consumePending(
            afterSequence: 0,
            screenInstanceId: nil,
            currentTopScreenInstanceId: nil
        )
        #expect(customIds(delivered) == ["ev_03", "ev_03b"])
    }

    /// SDK-1088: a subscriber that arms after a custom event was published
    /// must not get it, neither on arming nor on the next live revision.
    @Test("A subscriber armed after publication never receives the custom event")
    func lateSubscriberSkipsEarlierCustomEvents() {
        let bus = AdaptyUIEventBus()
        publishCustom(bus, "hide_sheet")

        let armed = bus.consumePending(
            afterSequence: 0,
            screenInstanceId: nil,
            currentTopScreenInstanceId: nil,
            includeCustom: false
        )
        #expect(armed.isEmpty)
        let cursor = bus.lastSequence

        publishCustom(bus, "next")
        let live = bus.consumePending(
            afterSequence: cursor,
            screenInstanceId: nil,
            currentTopScreenInstanceId: nil
        )
        #expect(customIds(live) == ["next"])
    }

    @Test("The buffer keeps only the newest custom events")
    func customEventsAreCapped() {
        let bus = AdaptyUIEventBus()
        for index in 0 ... AdaptyUIEventBus.customEventsLimit {
            publishCustom(bus, "ev_\(index)")
        }

        let ids = customIds(bus.pendingEvents)
        #expect(ids.count == AdaptyUIEventBus.customEventsLimit)
        #expect(ids.first == "ev_1")
    }
}

#endif
