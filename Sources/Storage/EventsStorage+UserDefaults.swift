//
//  EventsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults {
    private enum Constants {
        static let defaultName = ""
        static let syslogName = "SysLog"
    }

    var defaultEventsStorage: UserDefaultsEventsStorage {
        UserDefaultsEventsStorage(name: Constants.defaultName, userDefaults: self)
    }

    var sysLogEventsStorage: UserDefaultsEventsStorage {
        UserDefaultsEventsStorage(name: Constants.syslogName, userDefaults: self)
    }

    func clearEvents() {
        Log.debug("UserDefaults: Clear events.")
        [
            Constants.defaultName,
            Constants.syslogName,
        ]
        .flatMap {
            [
                UserDefaultsEventsStorage.eventsStorageKey($0),
                UserDefaultsEventsStorage.eventCounterKey($0),
            ]
        }
        .forEach {
            removeObject(forKey: $0)
        }
    }
}

final class UserDefaultsEventsStorage: EventsStorage {
    private let eventsStorageKey: String
    private let eventCounterKey: String
    private let name: String
    private let userDefaults: UserDefaults

    fileprivate static func eventsStorageKey(_ name: String) -> String { "AdaptySDK_Cached_\(name)Events" }
    fileprivate static func eventCounterKey(_ name: String) -> String { "AdaptySDK_\(name)Event_Counter" }

    fileprivate init(name: String, userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.name = name
        eventsStorageKey = UserDefaultsEventsStorage.eventsStorageKey(name)
        eventCounterKey = UserDefaultsEventsStorage.eventCounterKey(name)
    }

    func setEventCounter(_ value: Int) {
        Log.debug("UserDefaults: Save \(self.name)Event Counter = \(value) success.")
        userDefaults.set(value, forKey: eventCounterKey)
    }

    func getEventCounter() -> Int { userDefaults.integer(forKey: eventCounterKey) }

    func setEvents(_ value: [Data]) {
        Log.debug("UserDefaults: Save \(self.name)Events success.")
        userDefaults.set(value, forKey: eventsStorageKey)
    }

    func getEvents() -> [Data]? { userDefaults.object(forKey: eventsStorageKey) as? [Data] }
}
