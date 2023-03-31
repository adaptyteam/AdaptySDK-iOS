//
//  EventsStorage.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

protocol EventsStorage: AnyObject {
    func setEvents(_ value: [Data])
    func getEvents() -> [Data]?
    var profileId: String { get }
    var externalAnalyticsDisabled: Bool { get }
}

class EventCollectionStorage {
    private enum Constants {
        static let limitEvents = 50
    }

    private let storage: EventsStorage
    private var events: EventCollection<(String, Data)>

    struct Events {
        let elements: [Data]
        let endIndex: Int
    }

    var isEmpty: Bool { events.isEmpty }

    init(with storage: EventsStorage) {
        self.storage = storage
        var events = EventCollection<(String, Data)>(elements: storage.getEvents() ?? [], startIndex: 0)
        events.remove(toLimit: Constants.limitEvents)
        self.events = events
    }

    func getEvents(limit: Int, blackList: Set<String>) -> Events? {
        guard limit > 0, !events.isEmpty else { return nil }
        var elements = [Data]()
        var count = 0

        for item in events.elements {
            guard elements.count < limit else { break }
            count += 1
            if !blackList.contains(item.0) {
                elements.append(item.1)
            }
        }

        return Events(elements: elements, endIndex: events.endIndex(count))
    }

    func add(_ event: Event) throws {
        let data = try event.encodeToData()
        events.append((event.type.name, data), withLimit: Constants.limitEvents)
        storage.setEvents(events.elements.map { $1 })
    }

    func subtract(newStartIndex: Int) {
        let startIndex = events.startIndex
        events.subtract(newStartIndex: newStartIndex)
        guard startIndex != events.startIndex else { return }
        storage.setEvents(events.elements.map { $1 })
    }
}

extension EventCollectionStorage {
    var profileId: String { storage.profileId }
    var externalAnalyticsDisabled: Bool { storage.externalAnalyticsDisabled }
}

extension EventsStorage {
    fileprivate func getEvents() -> [(String, Data)]? {
        guard let array: [Data] = getEvents() else { return nil }
        return array.compactMap {
            guard let name = try? Event.decodeName($0) else { return nil }
            return (name, $0)
        }
    }
}
