//
//  EventsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

final class EventsManager {
    private enum Constants {
        static let sendingLimitEvents = 500
    }

    typealias ErrorHandler = (EventsError) -> Void
    private static let defaultDispatchQueue = DispatchQueue(label: "Adapty.SDK.SendEvents")

    private let dispatchQueue: DispatchQueue
    private let profileStorage: ProfileIdentifierStorage
    private let eventStorages: [EventCollectionStorage]
    private var configuration: EventsBackendConfiguration
    private let backendSession: HTTPSession?
    private var sending: Bool = false

    convenience init(profileStorage: ProfileIdentifierStorage, backend: Backend? = nil) {
        self.init(
            profileStorage: profileStorage,
            eventStorages: [
                UserDefaults.standard.defaultEventsStorage,
                UserDefaults.standard.sysLogEventsStorage,
            ],
            backend: backend
        )
    }

    convenience init(
        dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
        profileStorage: ProfileIdentifierStorage,
        eventStorages: [EventsStorage],
        backend: Backend?
    ) {
        self.init(
            dispatchQueue: dispatchQueue,
            profileStorage: profileStorage,
            eventStorages: eventStorages.map { EventCollectionStorage(with: $0) },
            backend: backend
        )
    }

    init(
        dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
        profileStorage: ProfileIdentifierStorage,
        eventStorages: [EventCollectionStorage],
        backend: Backend?
    ) {
        self.profileStorage = profileStorage
        self.eventStorages = eventStorages
        self.dispatchQueue = dispatchQueue

        let configuration = EventsBackendConfiguration()
        self.configuration = configuration

        guard let backend else {
            backendSession = nil
            return
        }
        backendSession = backend.createHTTPSession(responseQueue: dispatchQueue)
        if eventStorages.hasEvents || configuration.isExpired { needSendEvents() }
    }

    func trackEvent(_ event: Event, completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self else {
                completion(nil)
                return
            }

            guard !self.configuration.blacklist.contains(event.type.name) else {
                completion(nil)
                return
            }

            do {
                if event.lowPriority {
                    try self.eventStorages.last?.add(event)
                } else {
                    try self.eventStorages.first?.add(event)
                }
            } catch {
                let error = EventsError.encoding(error)
                completion(error)
                Log.error(error.description)
                return
            }

            self.needSendEvents()
            completion(nil)
        }
    }

    private func needSendEvents() {
        dispatchQueue.async { [weak self] in
            guard let self, let session = self.backendSession, !self.sending else { return }

            self.sending = true
            self._sendEvents(session) { [weak self] error in
                guard let self else { return }

                var retryAt: DispatchTime?
                if let error, !error.isInterrupted {
                    retryAt = .now() + .seconds(20)
                } else if self.eventStorages.hasEvents {
                    retryAt = .now() + .seconds(1)
                }

                guard let deadline = retryAt else {
                    self.sending = false
                    return
                }

                self.dispatchQueue.asyncAfter(deadline: deadline) { [weak self] in
                    self?.sending = false
                    self?.needSendEvents()
                }
            }
        }
    }

    func _sendEvents(_ session: HTTPSession, completion: @escaping (EventsError?) -> Void) {
        _updateBackendConfigurationIfNeed(session) { [weak self] error in

            if let error {
                completion(error)
                return
            }

            guard let self else {
                completion(.interrupted())
                return
            }

            let events = self.eventStorages.getEvents(
                limit: Constants.sendingLimitEvents,
                blackList: self.configuration.blacklist
            )

            guard !events.elements.isEmpty else {
                self.eventStorages.subtract(oldIndexes: events.endIndex)
                completion(nil)
                return
            }

            let request = SendEventsRequest(profileId: self.profileStorage.profileId, events: events.elements)

            session.perform(request) { (result: SendEventsRequest.Result) in
                switch result {
                case let .failure(error):
                    completion(.sending(error))
                case .success:
                    self.eventStorages.subtract(oldIndexes: events.endIndex)
                    completion(nil)
                }
            }
        }
    }

    func _updateBackendConfigurationIfNeed(_ session: HTTPSession, completion: @escaping (EventsError?) -> Void) {
        guard configuration.isExpired else {
            completion(nil)
            return
        }

        session.perform(FetchEventsConfigRequest(profileId: profileStorage.profileId), logName: "get_events_blacklist") { [weak self] (result: FetchEventsConfigRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.sending(error))
            case let .success(response):
                self?.configuration = response.body.value
                completion(nil)
            }
        }
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
