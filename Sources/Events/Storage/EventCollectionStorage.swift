//
//  EventCollectionStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.09.2024
//

import Foundation

private let log = Log.events

@EventsManagerActor
final class EventCollectionStorage {
    private enum Constants {
        static let limitEvents = 500
    }

    private let storage: EventsStorage
    private var events: EventCollection<Event.Packed>

    var isEmpty: Bool { events.isEmpty }

    init(with storage: EventsStorage) {
        self.storage = storage
        var events = EventCollection<Event.Packed>(elements: storage.getEvents() ?? [], startIndex: 0)
        events.remove(toLimit: Constants.limitEvents)
        self.events = events
    }

    func getEvents(limit: Int, blackList: Set<String>) -> (elements: [Data], endIndex: Int)? {
        guard limit > 0, !events.isEmpty else { return nil }
        var elements = [Data]()
        var count = 0

        for event in events.elements {
            guard elements.count < limit else { break }
            count += 1
            if !blackList.contains(event.name) {
                elements.append(event.data)
            } else {
                log.verbose("Event \(event.name) #\(event.counter) blacklisted")
            }
        }

        return (elements, events.endIndex(count))
    }

    func add(_ event: Event.Unpacked) throws {
        let event = try Event.Packed(from: event, counter: storage.eventsCount)
        storage.incrementEventCount()
        let old = events.elements.first
        events.append(event, withLimit: Constants.limitEvents)
        if let old, old.id != events.elements.first?.id {
            log.verbose("Event \(old.name) #\(old.counter) deleted due to exceeded the limit of \(Constants.limitEvents)")
        }
        storage.setEvents(events.elements.map { $0.data })
    }

    func subtract(newStartIndex: Int) {
        let startIndex = events.startIndex
        events.subtract(newStartIndex: newStartIndex)
        guard startIndex != events.startIndex else { return }
        storage.setEvents(events.elements.map { $0.data })
    }
}

private extension EventsStorage {
    func getEvents() -> [Event.Packed]? {
        guard let array: [Data] = events else { return nil }
        return array.compactMap {
            do {
                return try Event.Packed(from: $0)
            } catch {
                let error = EventsError.decoding(error)
                log.error("Event skipped due to error \(error.description)")
                return nil
            }
        }
    }
}
