//
//  EventsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

protocol EventsStorage: AnyObject {
    func setEventCounter(_: Int)
    func getEventCounter() -> Int

    func setEvents(_: [Data])
    func getEvents() -> [Data]?
}

final class EventCollectionStorage {
    private enum Constants {
        static let limitEvents = 500
    }

    private let storage: EventsStorage
    private var events: EventCollection<Event.Info>
    private var eventCounter: Int

    var isEmpty: Bool { events.isEmpty }

    init(with storage: EventsStorage) {
        self.storage = storage
        eventCounter = storage.getEventCounter()
        var events = EventCollection<Event.Info>(elements: storage.getEvents() ?? [], startIndex: 0)
        events.remove(toLimit: Constants.limitEvents)
        self.events = events
    }

    func getEvents(limit: Int, blackList: Set<String>) -> (elements: [Data], endIndex: Int)? {
        guard limit > 0, !events.isEmpty else { return nil }
        var elements = [Data]()
        var count = 0

        for item in events.elements {
            guard elements.count < limit else { break }
            count += 1
            if !blackList.contains(item.type) {
                elements.append(item.data)
            } else {
                Log.verbose("Events: event \(item.type) #\(item.counter) blacklisted")
            }
        }

        return (elements, events.endIndex(count))
    }

    func add(_ event: Event) throws {
        var event = event
        event.counter = eventCounter
        let info = try Event.Info(from: event)
        eventCounter += 1
        let old = events.elements.first
        events.append(info, withLimit: Constants.limitEvents)
        if let item = old, item.id != events.elements.first?.id {
            Log.verbose("Events: event \(item.type) #\(item.counter) deleted due to exceeded the limit of \(Constants.limitEvents)")
        }
        storage.setEventCounter(eventCounter)
        storage.setEvents(events.elements.map { $0.data })
    }

    func subtract(newStartIndex: Int) {
        let startIndex = events.startIndex
        events.subtract(newStartIndex: newStartIndex)
        guard startIndex != events.startIndex else { return }
        storage.setEvents(events.elements.map { $0.data })
    }
}

extension EventsStorage {
    fileprivate func getEvents() -> [Event.Info]? {
        guard let array: [Data] = getEvents() else { return nil }
        return array.compactMap {
            do {
                let info = try Event.decodeFromData($0)
                return info
            } catch {
                let error = EventsError.decoding(error)
                Log.error("Events: event skipped due to error \(error.description)")
                return nil
            }
        }
    }
}
