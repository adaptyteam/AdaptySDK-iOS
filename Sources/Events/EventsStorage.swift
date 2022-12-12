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
    private var events: EventCollection<Data>

    struct Events {
        let elements: [Data]
        let endIndex: Int
    }

    var isEmpty: Bool { events.isEmpty }

    init(with storage: EventsStorage) {
        self.storage = storage
        var events = EventCollection(elements: storage.getEvents() ?? [], startIndex: 0)
        events.remove(toLimit: Constants.limitEvents)
        self.events = events
    }

    func getEvents() -> Events? {
        events.isEmpty ? nil : Events(elements: events.elements, endIndex: events.endIndex)
    }

    func add(_ event: Event) throws {
        events.append(try event.encodeToData(), withLimit: Constants.limitEvents)
        storage.setEvents(events.elements)
    }

    func subtract(newStartIndex: Int) {
        let startIndex = events.startIndex
        events.subtract(newStartIndex: newStartIndex)
        guard startIndex != events.startIndex else { return }
        storage.setEvents(events.elements)
    }
}

extension EventCollectionStorage {
    var profileId: String { storage.profileId }
    var externalAnalyticsDisabled: Bool { storage.externalAnalyticsDisabled }
}
