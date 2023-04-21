//
//  EventsManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

protocol EventsBackendConfigurationStorage: AnyObject {
    func setEventsConfiguration(_ value: EventsBackendConfiguration)
    func getEventsConfiguration() -> EventsBackendConfiguration?
}

final class EventsManager {
    private enum Constants {
        static let sendingLimitEvents = 500
    }

    typealias ErrorHandler = (EventsError) -> Void
    private static let defaultDispatchQueue = DispatchQueue(label: "Adapty.SDK.SendEvents")

    private let dispatchQueue: DispatchQueue
    private let storage: EventCollectionStorage
    private let configurationStorage: EventsBackendConfigurationStorage
    private var configuration: EventsBackendConfiguration
    private let backendSession: HTTPSession?
    private var sending: Bool = false

    convenience init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
                     storage: EventsStorage & EventsBackendConfigurationStorage,
                     backend: Backend?) {
        self.init(dispatchQueue: dispatchQueue,
                  storage: EventCollectionStorage(with: storage),
                  configurationStorage: storage,
                  backend: backend)
    }

    init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
         storage: EventCollectionStorage,
         configurationStorage: EventsBackendConfigurationStorage,
         backend: Backend?) {
        self.storage = storage
        self.dispatchQueue = dispatchQueue
        self.configurationStorage = configurationStorage

        var configuration = configurationStorage.getEventsConfiguration() ?? EventsBackendConfiguration()
        if !Adapty.Configuration.sendSystemEventsEnabled {
            configuration.blacklist.formUnion(EventType.systemEvents)
        }
        self.configuration = configuration

        guard let backend = backend else {
            backendSession = nil
            return
        }
        backendSession = backend.createHTTPSession(responseQueue: dispatchQueue)
        if !storage.isEmpty || configuration.isExpired { needSendEvents() }
    }

    func trackEvent(_ event: Event, completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard !self.configuration.blacklist.contains(event.type.name) else {
                completion(nil)
                return
            }

            do {
                try self.storage.add(event)
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
            guard let self = self, let session = self.backendSession, !self.sending else { return }

            self.sending = true
            self._sendEvents(session) { [weak self] error in
                defer { self?.sending = false }
                guard let self = self else { return }

                var retryAt: DispatchTime?
                if let error = error, !error.isInterrupted { retryAt = .now() + .seconds(20) }
                else if !self.storage.isEmpty { retryAt = .now() + .seconds(1) }

                guard let deadline = retryAt else { return }
                self.dispatchQueue.asyncAfter(deadline: deadline) { [weak self] in
                    self?.needSendEvents()
                }
            }
        }
    }

    func _sendEvents(_ session: HTTPSession, completion: @escaping (EventsError?) -> Void) {
        _updateBackendConfigurationIfNeed(session) { [weak self] error in

            if let error = error {
                completion(error)
                return
            }

            guard let self = self else {
                completion(.interrupted())
                return
            }

            guard let events = self.storage.getEvents(limit: Constants.sendingLimitEvents, blackList: self.configuration.blacklist) else {
                completion(nil)
                return
            }

            guard !events.elements.isEmpty else {
                self.storage.subtract(newStartIndex: events.endIndex + 1)
                completion(nil)
                return
            }

            let request = SendEventsRequest(profileId: self.storage.profileId, events: events.elements)

            session.perform(request) {
                (result: SendEventsRequest.Result) in
                switch result {
                case let .failure(error):
                    completion(.sending(error))
                case .success:
                    self.storage.subtract(newStartIndex: events.endIndex + 1)
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

        session.perform(FetchEventsConfigRequest(profileId: storage.profileId), logName: "get_events_blacklist") { [weak self] (result: FetchEventsConfigRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.sending(error))
            case let .success(response):
                var configuration = response.body.value
                self?.configurationStorage.setEventsConfiguration(configuration)
                if !Adapty.Configuration.sendSystemEventsEnabled {
                    configuration.blacklist.formUnion(EventType.systemEvents)
                }
                self?.configuration = configuration
                completion(nil)
            }
        }
    }
}
