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

    func set(backend: Backend) {
        backendSession = backend.createEventsExecutor()
        guard eventStorages.hasEvents || configuration.isExpired else { return }
        needSendEvents()
    }

    func trackEvent(_ unpacked: Event.Unpacked) throws {
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

        Task(priority: .utility) { [weak self] in

            var error: Error?
            do {
                try await self?.sendEvents(backendSession)
            } catch let err {
                error = err
            }

            let interval: TaskDuration? =
                if let error, !((error as? EventsError)?.isInterrupted ?? false) {
                    .seconds(20)
                } else if self?.hasEvents() ?? false {
                    .seconds(1)
                } else {
                    nil
                }

            guard let interval else {
                self?.finishSending()
                return
            }

            Task.detached(priority: .utility) { [weak self] in
                try? await Task.sleep(duration: interval)
                await self?.finishSending()
                await self?.needSendEvents() // TODO: recursion ???
            }
        }
    }

    private func sendEvents(_ session: Backend.EventsExecutor) async throws {
        if configuration.isExpired {
            configuration = try await session.fetchEventsConfig(
                profileId: ProfileStorage.profileId
            )
        }

        let events = eventStorages.getEvents(
            limit: Constants.sendingLimitEvents,
            blackList: configuration.blacklist
        )

        guard !events.elements.isEmpty else {
            eventStorages.subtract(oldIndexes: events.endIndex)
            return
        }

        try await session.sendEvents(
            profileId: ProfileStorage.profileId,
            events: events.elements
        )

        eventStorages.subtract(oldIndexes: events.endIndex)
    }

    private func finishSending() {
        sending = false
    }
}

@EventsManagerActor
private extension [EventCollectionStorage] {
    var hasEvents: Bool { contains { !$0.isEmpty } }

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
