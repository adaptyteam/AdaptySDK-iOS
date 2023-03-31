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
        static let sendingLimitEvents = 10
    }

    typealias ErrorHandler = (EventsError) -> Void
    private static let defaultDispatchQueue = DispatchQueue(label: "Adapty.SDK.SendEvents")

    private let dispatchQueue: DispatchQueue
    private let storage: EventCollectionStorage
    private let configurationStorage: EventsBackendConfigurationStorage
    private var configuration: EventsBackendConfiguration?
    private let backendSession: HTTPSession
    private var sending: Bool = false

    convenience init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
                     storage: EventsStorage & EventsBackendConfigurationStorage,
                     backend: Backend) {
        self.init(dispatchQueue: dispatchQueue,
                  storage: EventCollectionStorage(with: storage),
                  configurationStorage: storage,
                  backend: backend)
    }

    init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
         storage: EventCollectionStorage,
         configurationStorage: EventsBackendConfigurationStorage,
         backend: Backend) {
        self.storage = storage
        self.dispatchQueue = dispatchQueue
        self.configurationStorage = configurationStorage

        backendSession = backend.createHTTPSession(responseQueue: dispatchQueue)
        configuration = configurationStorage.getEventsConfiguration()
        if !storage.isEmpty || configuration == nil { needSendEvents() }
    }

    func trackEvent(_ event: Event, _ ifEnabled: Bool, completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard !(self.configuration?.isBlocked(event) ?? false) else {
                completion(nil)
                return
            }

            guard !self.storage.externalAnalyticsDisabled else {
                let error = EventsError.analyticsDisabled()
                completion(error)
                if !ifEnabled { Log.warn(error.description) }
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
            guard let self = self, !self.sending else { return }

            self.sending = true
            self._sendEvents { [weak self] error in
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

    func _sendEvents(completion: @escaping (EventsError?) -> Void) {
        _updateBackendConfigurationIfNeed { [weak self] error in

            if let error = error {
                completion(error)
                return
            }

            guard let self = self else {
                completion(.interrupted())
                return
            }

            guard let events = self.storage.getEvents(limit: Constants.sendingLimitEvents, blackList: self.configuration?.blacklist) else {
                completion(nil)
                return
            }

            guard !events.elements.isEmpty else {
                self.storage.subtract(newStartIndex: events.endIndex + 1)
                completion(nil)
                return
            }

            self.backendSession.perform(SendEventsRequest(profileId: self.storage.profileId, events: events.elements)) {
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

    func _updateBackendConfigurationIfNeed(completion: @escaping (EventsError?) -> Void) {
        guard configuration?.isExpired ?? true else {
            completion(nil)
            return
        }

        backendSession.perform(FetchEventsConfigRequest(profileId: storage.profileId)) { [weak self] (result: FetchEventsConfigRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.sending(error))
            case let .success(response):
                let configuration = response.body.value
                self?.configuration = configuration
                self?.configurationStorage.setEventsConfiguration(configuration)
                completion(nil)
            }
        }
    }
}
