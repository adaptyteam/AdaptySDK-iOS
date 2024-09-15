//
//  EventsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

private enum EventsGroup: String {
    case `default` = ""
    case syslog = "SysLog"

    @inlinable var name: String { rawValue }
    @inlinable var eventsStorageKey: String { "AdaptySDK_Cached_\(rawValue)Events" }
    @inlinable var eventCounterKey: String { "AdaptySDK_\(rawValue)Event_Counter" }
}

extension UserDefaults {
    var defaultEventsStorage: UserDefaultsEventsStorage {
        UserDefaultsEventsStorage(group: .default, userDefaults: self)
    }

    var sysLogEventsStorage: UserDefaultsEventsStorage {
        UserDefaultsEventsStorage(group: .syslog, userDefaults: self)
    }

    func clearEvents() {
        removeObject(forKey: EventsGroup.default.eventsStorageKey)
        removeObject(forKey: EventsGroup.default.eventCounterKey)
        removeObject(forKey: EventsGroup.syslog.eventsStorageKey)
        removeObject(forKey: EventsGroup.syslog.eventCounterKey)
    }
}

final class UserDefaultsEventsStorage: EventsStorage {
    private let group: EventsGroup
    private let userDefaults: UserDefaults

    fileprivate init(group: EventsGroup, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.group = group
    }

    func setEventCounter(_ value: Int) {
        log.debug("Save \(group.name)Event Counter = \(value) success.")
        userDefaults.set(value, forKey: group.eventCounterKey)
    }

    func getEventCounter() -> Int { userDefaults.integer(forKey: group.eventCounterKey) }

    func setEvents(_ value: [Data]) {
        log.debug("Save \(group.name)Events success.")
        userDefaults.set(value, forKey: group.eventsStorageKey)
    }

    func getEvents() -> [Data]? { userDefaults.object(forKey: group.eventsStorageKey) as? [Data] }
}
