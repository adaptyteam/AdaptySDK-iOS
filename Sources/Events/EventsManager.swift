//
//  EventsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

private let log = Log.events

@EventsManagerActor
final class EventsManager {
    static var shared: EventsManager?

    private enum Constants {
        static let sendingLimitEvents = 500
    }

    private let eventStorages = EventsStorage.all.map { EventCollectionStorage(with: $0) }
    private var configuration = EventsBackendConfiguration()
    private var backendSession: Backend.EventsExecutor?
    private var sending: Bool = false

    func set(backend: Backend, with configuration: EventsBackendConfiguration) {
        backendSession = backend.createEventsExecutor()
        self.configuration = configuration
        guard eventStorages.hasEvents || configuration.isExpired else { return }
        needSendEvents()
    }

    func trackEvent(_ unpacked: Event.Unpacked) throws(EventsError) {
        guard !configuration.blacklist.contains(unpacked.event.name) else {
            return
        }

        do {
            if unpacked.event.isLowPriority {
                try eventStorages.last?.add(unpacked)
            } else {
                try eventStorages.first?.add(unpacked)
            }
        } catch {
            let error = EventsError.encoding(error)
            log.error(error.description)
            throw error
        }

        needSendEvents()
    }

    private func hasEvents() -> Bool {
        eventStorages.hasEvents
    }

    private func needSendEvents() {
        guard let backendSession, !sending else { return }

        sending = true

        Task.detached(priority: .utility) { @EventsManagerActor @Sendable [weak self] in
            defer { self?.sending = false }
            while !Task.isCancelled {
                let interval: TaskDuration
                do throws(EventsError) {
                    try await self?.sendEvents(backendSession)

                    guard self?.hasEvents() ?? false else { return }
                    interval = .seconds(1)

                } catch {
                    guard !error.isInterrupted else { return }
                    interval = .seconds(20)
                }

                try await Task.sleep(duration: interval)
            }
        }
    }

    private func sendEvents(_ session: Backend.EventsExecutor) async throws(EventsError) {
        let currentState = await session.networkManager.fetchCurrentState()
        configuration = .init(currentState)

        let events = eventStorages.getEvents(
            limit: Constants.sendingLimitEvents,
            blackList: configuration.blacklist
        )

        guard events.elements.isNotEmpty else {
            eventStorages.subtract(oldIndexes: events.endIndex)
            return
        }

        try await session.sendEvents(
            userId: ProfileStorage.userId,
            events: events.elements
        )

        eventStorages.subtract(oldIndexes: events.endIndex)
    }
}

@EventsManagerActor
private extension [EventCollectionStorage] {
    var hasEvents: Bool { contains { $0.isNotEmpty } }

    func getEvents(limit: Int, blackList: Set<String>) -> (elements: [Data], endIndex: [Int?]) {
        var limit = limit
        let initResult = (elements: [Data](), endIndex: [Int?]())
        return reduce(initResult) { result, storage in
            guard limit > 0,
                  let (elements, endIndex) = storage.getEvents(limit: limit, blackList: blackList)
            else {
                return (result.elements, result.endIndex + [nil])
            }

            limit -= elements.count
            return (result.elements + elements, result.endIndex + [endIndex])
        }
    }

    func subtract(oldIndexes: [Int?]) {
        for (optionalIndex, storage) in zip(oldIndexes, self) {
            guard let index = optionalIndex else { continue }
            storage.subtract(newStartIndex: index + 1)
        }
    }
}
