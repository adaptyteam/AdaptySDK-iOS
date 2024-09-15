//
//  EventsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

private let log = Log.events

actor EventsManager {
    private enum Constants {
        static let sendingLimitEvents = 500
    }

    private let profileStorage: ProfileIdentifierStorage
    private let eventStorages: [EventCollectionStorage]
    private var configuration: EventsBackendConfiguration
    private var backendSession: HTTPSession?
    private var sending: Bool = false

    init(
        profileStorage: ProfileIdentifierStorage
    ) {
        self.init(
            profileStorage: profileStorage,
            eventStorages: [
                UserDefaults.standard.defaultEventsStorage,
                UserDefaults.standard.sysLogEventsStorage,
            ]
        )
    }

    init(
        profileStorage: ProfileIdentifierStorage,
        eventStorages: [EventsStorage]
    ) {
        self.init(
            profileStorage: profileStorage,
            eventStorages: eventStorages.map(EventCollectionStorage.init)
        )
    }

    init(
        profileStorage: ProfileIdentifierStorage,
        eventStorages: [EventCollectionStorage]
    ) {
        self.profileStorage = profileStorage
        self.eventStorages = eventStorages

        let configuration = EventsBackendConfiguration()
        self.configuration = configuration
    }

    func set(backend: Backend) {
        backendSession = backend.createHTTPSession()
        guard eventStorages.hasEvents || configuration.isExpired else { return }
        needSendEvents()
    }

    func trackEvent(_ unpacked: Event.Unpacked) throws {
        guard !configuration.blacklist.contains(unpacked.event.name.rawValue) else {
            return
        }

        do {
            if unpacked.event.isLowPriority {
                try self.eventStorages.last?.add(unpacked)
            } else {
                try self.eventStorages.first?.add(unpacked)
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

            let seconds: UInt64? =
                if let error, !((error as? EventsError)?.isInterrupted ?? false) {
                    20
                } else if await (self?.hasEvents()) ?? false {
                    1
                } else {
                    nil
                }

            guard let seconds else {
                await self?.finishSending()
                return
            }

            Task.detached(priority: .utility) { [weak self] in
                try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                await self?.finishSending()
                await self?.needSendEvents()
            }
        }
    }

    private func sendEvents(_ session: HTTPSession) async throws {
        if configuration.isExpired {
            configuration = try await session.performFetchEventsConfigRequest(
                profileId: profileStorage.profileId
            )
        }

        let events = self.eventStorages.getEvents(
            limit: Constants.sendingLimitEvents,
            blackList: self.configuration.blacklist
        )

        guard !events.elements.isEmpty else {
            self.eventStorages.subtract(oldIndexes: events.endIndex)
            return
        }

        try await session.performSendEventsRequest(
            profileId: self.profileStorage.profileId,
            events: events.elements
        )

        self.eventStorages.subtract(oldIndexes: events.endIndex)
    }

    private func finishSending() {
        sending = false
    }
}

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
        zip(oldIndexes, self)
            .forEach { optionalIndex, storage in
                guard let index = optionalIndex else { return }
                storage.subtract(newStartIndex: index + 1)
            }
    }
}
