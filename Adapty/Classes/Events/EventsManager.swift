//
//  EventsManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

final class EventsManager {
    typealias ErrorHandler = (EventsError) -> Void
    private static let defaultDispatchQueue = DispatchQueue(label: "Adapty.SDK.SendEvents")

    private let dispatchQueue: DispatchQueue
    private let storage: EventCollectionStorage
    private let kinesis: Kinesis
    private let backendSession: HTTPSession
    private let kinesisSession: HTTPSession
    private var sending: Bool = false

    convenience init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
                     storage: EventsStorage,
                     backend: Backend,
                     kinesis: Kinesis = Kinesis(credentials: nil)) {
        self.init(dispatchQueue: dispatchQueue,
                  storage: EventCollectionStorage(with: storage),
                  backend: backend,
                  kinesis: kinesis)
    }

    init(dispatchQueue: DispatchQueue = EventsManager.defaultDispatchQueue,
         storage: EventCollectionStorage,
         backend: Backend,
         kinesis: Kinesis = Kinesis(credentials: nil)) {
        self.storage = storage
        self.dispatchQueue = dispatchQueue
        self.kinesis = kinesis

        backendSession = backend.createHTTPSession(responseQueue: dispatchQueue)
        kinesisSession = kinesis.createHTTPSession(responseQueue: dispatchQueue)
        if !storage.isEmpty { needSendEvents() }
    }

    func trackEvent(_ event: Event, completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard !self.storage.externalAnalyticsDisabled else {
                let error = EventsError.analyticsDisabled()
                completion(error)
                Log.warn(error.description)
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
            self.sendEvents { [weak self] error in
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

    private func updateCredential(completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let self = self else {
                completion(.interrupted())
                return
            }
            if let credentials = self.kinesis.credentials, credentials.expiration > Date() {
                completion(nil)
                return
            }

            self.kinesis.credentials = nil
            self.backendSession.perform(FetchKinesisCredentialsRequest(profileId: self.storage.profileId)) { [weak self] (result: FetchKinesisCredentialsRequest.Result) in
                switch result {
                case let .failure(error):
                    completion(.sending(error))
                case let .success(response):
                    self?.kinesis.credentials = response.body.value
                    completion(nil)
                }
            }
        }
    }

    private func sendEvents(completion: @escaping (EventsError?) -> Void) {
        dispatchQueue.async { [weak self] in
            self?.updateCredential { error in
                if let error = error {
                    completion(error)
                    return
                }

                guard let events = self?.storage.getEvents() else {
                    completion(nil)
                    return
                }

                self?.kinesisSession.perform(SendEventsRequest(events: events.elements, streamName: Kinesis.Configuration.publicStreamName)) {
                    (result: SendEventsRequest.Result) in
                    switch result {
                    case let .failure(error):
                        completion(.sending(error))
                    case .success:
                        self?.storage.subtract(newStartIndex: events.endIndex + 1)
                        completion(nil)
                    }
                }
            }
        }
    }
}
