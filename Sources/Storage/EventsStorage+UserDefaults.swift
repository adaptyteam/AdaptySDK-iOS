//
//  EventsStorage+UserDefaults.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: EventsStorage {
    fileprivate enum Constants {
        static let eventsStorageKey = "AdaptySDK_Cached_Events"
        static let eventCounterKey = "AdaptySDK_Event_Counter"
    }

    func setEventCounter(_ value: Int) {
        Log.debug("UserDefaults: Save Event Counter = \(value) success.")
        set(value, forKey: Constants.eventCounterKey)
    }

    func getEventCounter() -> Int { integer(forKey: Constants.eventCounterKey) }

    func setEvents(_ value: [Data]) {
        Log.debug("UserDefaults: Save Events success.")
        set(value, forKey: Constants.eventsStorageKey)
    }

    func getEvents() -> [Data]? { object(forKey: Constants.eventsStorageKey) as? [Data] }

    func clearEvents() {
        Log.debug("UserDefaults: Clear events.")
        removeObject(forKey: Constants.eventCounterKey)
        removeObject(forKey: Constants.eventsStorageKey)
    }
}
