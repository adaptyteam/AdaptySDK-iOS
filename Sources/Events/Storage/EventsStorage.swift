//
//  EventsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

@EventsManagerActor
final class EventsStorage: Sendable {
    static var all = Kind.allCases.map { EventsStorage(kind: $0) }

    private let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    var eventsCount: Int { AllEventsStorage.eventsCount[kind] ?? 0 }
    var events: [Data]? { AllEventsStorage.events[kind] ?? nil }

    func incrementEventCount() { AllEventsStorage.incrementEventCount(kind) }
    func setEvents(_ value: [Data]) { AllEventsStorage.setEvents(value, kind) }
    func clear() { AllEventsStorage.clear(kind) }

    static func clearAll() {
        all.forEach { $0.clear() }
    }
}

private enum Kind: Sendable, Hashable, CaseIterable {
    case defaultEvents
    case sysLogEvents

    var prefix: String {
        switch self {
        case .defaultEvents: ""
        case .sysLogEvents: "SysLog"
        }
    }

    var eventsKey: String { "AdaptySDK_Cached_\(prefix)Events" }
    var counterKey: String { "AdaptySDK_\(prefix)Event_Counter" }
}

@EventsManagerActor
private final class AllEventsStorage: Sendable {
    private static let userDefaults = Storage.userDefaults

    static var eventsCount: [Kind: Int] = Dictionary(Kind.allCases.map {
        ($0, userDefaults.integer(forKey: $0.counterKey))
    }) { first, _ in first }

    static var events: [Kind: [Data]?] = Dictionary(Kind.allCases.map {
        ($0, userDefaults.object(forKey: $0.eventsKey) as? [Data])
    }) { first, _ in first }

    static func incrementEventCount(_ kind: Kind) {
        let nextValue = (eventsCount[kind] ?? 0) + 1
        userDefaults.set(nextValue, forKey: kind.counterKey)
        eventsCount[kind] = nextValue
        log.debug("Save \(kind.prefix)Event Counter = \(nextValue) success.")
    }

    static func setEvents(_ value: [Data], _ kind: Kind) {
        userDefaults.set(value, forKey: kind.eventsKey)
        events[kind] = value
        log.debug("Save \(kind.prefix)Events success.")
    }

    static func clear(_ kind: Kind) {
        userDefaults.removeObject(forKey: kind.counterKey)
        userDefaults.removeObject(forKey: kind.eventsKey)
        events[kind] = nil
        eventsCount[kind] = 0
    }
}
