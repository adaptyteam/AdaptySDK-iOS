//
//  Adapty+ChangeState.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

public final class Adapty {
    static var shared: Adapty?
    let profileStorage: ProfileStorage
    let backend: Backend
    let httpSession: HTTPSession
    let eventsManager: EventsManager
    let skProductsManager: SKProductsManager
    let skReceiptManager: SKReceiptManager
    let skQueueManager: SKQueueManager
    let vendorIdsCache: ProductVendorIdsCache
    var onceSendedEnvoriment: Bool = false
    var state: State

    init(profileStorage: ProfileStorage,
         vendorIdsStorage: ProductVendorIdsStorage,
         backend: Backend,
         customerUserId: String?) {
        self.backend = backend
        self.profileStorage = profileStorage
        vendorIdsCache = ProductVendorIdsCache(storage: vendorIdsStorage)
        httpSession = backend.createHTTPSession(responseQueue: Adapty.underlayQueue)

        skProductsManager = SKProductsManager(storage: UserDefaults.standard, backend: backend)
        skReceiptManager = SKReceiptManager(queue: Adapty.underlayQueue)
        skQueueManager = SKQueueManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard)
        eventsManager = EventsManager(storage: UserDefaults.standard, backend: backend)
        state = .initilizingTo(customerUserId: customerUserId)

        skReceiptManager.prepare()
        skQueueManager.startObserving(receiptValidator: self)
        initilizingProfileManager(toCustomerUserId: customerUserId)
    }

    fileprivate var profileManagerCompletionHandlers: [AdaptyResultCompletion<AdaptyProfileManager>]?

    fileprivate var logoutCompletionHandlers: [AdaptyErrorCompletion]?

    @inline(__always)
    func getProfileManager(_ completion: @escaping AdaptyResultCompletion<AdaptyProfileManager>) {
        if let result = state.initilizedResult {
            completion(result)
            return
        }
        if let handlers = profileManagerCompletionHandlers {
            profileManagerCompletionHandlers = handlers + [completion]
            return
        }
        profileManagerCompletionHandlers = [completion]
    }

    @inline(__always)
    fileprivate func callProfileManagerCompletionHandlers(_ result: AdaptyResult<AdaptyProfileManager>) {
        guard let handlers = profileManagerCompletionHandlers else { return }
        profileManagerCompletionHandlers = nil
        Adapty.underlayQueue.async {
            handlers.forEach { $0(result) }
        }
    }

    @inline(__always)
    fileprivate func callLogoutCompletionHandlers(_ error: AdaptyError?) {
        guard let handlers = logoutCompletionHandlers else { return }
        logoutCompletionHandlers = nil
        Adapty.underlayQueue.async {
            handlers.forEach { $0(error) }
        }
    }
}

extension Adapty {
    @inline(__always)
    func startLogout(_ completion: @escaping AdaptyErrorCompletion) {
        if let handlers = logoutCompletionHandlers {
            logoutCompletionHandlers = handlers + [completion]
            return
        } else {
            logoutCompletionHandlers = [completion]
        }

        switch state {
        case let .failed(error):
            callLogoutCompletionHandlers(error)
            return
        case let .initilized(manager):
            manager.isActive = false
            finishLogout()
        case .initilizingTo,
             .needIdentifyTo,
             .needLogout:
            state = .needLogout
        }
    }

    @inline(__always)
    fileprivate func finishLogout() {
        profileStorage.clearProfile(newProfileId: nil)
        state = .initilizingTo(customerUserId: nil)
        callLogoutCompletionHandlers(nil)
        callProfileManagerCompletionHandlers(.failure(AdaptyError.profileWasChanged()))
        Adapty.underlayQueue.async { [weak self] in
            self?.initilizingProfileManager(toCustomerUserId: nil)
        }
    }

    @inline(__always)
    func identify(toCustomerUserId newCustomerUserId: String, _ completion: @escaping AdaptyErrorCompletion) {
        switch state {
        case let .failed(error):
            completion(error)
            return
        case let .initilized(manager):
            guard manager.profile.value.customerUserId != newCustomerUserId else {
                completion(nil)
                return
            }
            manager.isActive = false
            state = .initilizingTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(AdaptyError.profileWasChanged()))
            getProfileManager { completion($0.error) }
            Adapty.underlayQueue.async { [weak self] in
                self?.initilizingProfileManager(toCustomerUserId: newCustomerUserId)
            }
            return
        case let .initilizingTo(customerUserId):
            if let customerUserId = customerUserId, customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(AdaptyError.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case let .needIdentifyTo(customerUserId):
            if customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(AdaptyError.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case .needLogout:
            profileStorage.clearProfile(newProfileId: nil)
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(AdaptyError.profileWasChanged()))
            getProfileManager { completion($0.error) }
        }
    }

    @inline(__always)
    fileprivate func needBreakInitilizing() -> Bool {
        switch state {
        case .initilizingTo:
            return false
        case .failed, .initilized:
            return true
        case .needLogout:
            finishLogout()
            return true
        case let .needIdentifyTo(customerUserId):
            state = .initilizingTo(customerUserId: customerUserId)
            Adapty.underlayQueue.async { [weak self] in
                self?.initilizingProfileManager(toCustomerUserId: customerUserId)
            }
            return true
        }
    }

    fileprivate func initilizingProfileManager(toCustomerUserId customerUserId: String?) {
        guard !needBreakInitilizing() else { return }

        let profileId = profileStorage.profileId

        if let profile = profileStorage.getProfile(profileId: profileId, withCustomerUserId: customerUserId) {
            let manager = AdaptyProfileManager(manager: self,
                                               paywallStorage: UserDefaults.standard,
                                               productStorage: UserDefaults.standard,
                                               profile: profile)

            state = .initilized(manager)
            callProfileManagerCompletionHandlers(.success(manager))

            if !onceSendedEnvoriment {
                manager.getProfile { _ in }
            }
            return
        }

        createProfile(profileId, customerUserId) { [weak self] result in
            guard let self = self, !self.needBreakInitilizing() else { return }
            switch result {
            case .failure:
                // TODO: Dont repeat if wrong apiKey, and ???
                Adapty.underlayQueue.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.initilizingProfileManager(toCustomerUserId: customerUserId)
                }
            case let .success(profile):

                let manager = AdaptyProfileManager(manager: self,
                                                   paywallStorage: UserDefaults.standard,
                                                   productStorage: UserDefaults.standard,
                                                   profile: profile)

                self.state = .initilized(manager)
                self.callProfileManagerCompletionHandlers(.success(manager))
            }
        }
    }

    fileprivate func createProfile(_ profileId: String, _ customerUserId: String?, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        _ = httpSession.performCreateProfileRequest(profileId: profileId,
                                                    customerUserId: customerUserId,
                                                    analyticsDisabled: profileStorage.externalAnalyticsDisabled) { [weak self] result in
            guard let self = self else { return }

            // TODO: Check Cancel

            switch result {
            case let .failure(error):
                completion(.failure(error))
                break
            case let .success(profile):
                self.onceSendedEnvoriment = true

                let storage = self.profileStorage
                if profileId != profile.value.profileId {
                    storage.clearProfile(newProfileId: profile.value.profileId)
                }
                storage.setProfile(profile)

                self.validateReceipt(refreshIfEmpty: false) { _ in
                    completion(.success(profile))
                }
            }
        }
    }

    enum State {
        case initilizingTo(customerUserId: String?)
        case needLogout
        case needIdentifyTo(customerUserId: String)
        case failed(AdaptyError)
        case initilized(AdaptyProfileManager)

        var initilizing: Bool {
            switch self {
            case .failed, .initilized:
                return false
            default:
                return true
            }
        }

        var initilized: AdaptyProfileManager? {
            switch self {
            case let .initilized(manager):
                return manager
            default:
                return nil
            }
        }

        var initilizedResult: AdaptyResult<AdaptyProfileManager>? {
            switch self {
            case let .failed(error):
                return .failure(error)
            case let .initilized(manager):
                return .success(manager)
            default:
                return nil
            }
        }

        init(_ result: AdaptyResult<AdaptyProfileManager>) {
            switch result {
            case let .failure(error):
                self = .failed(error)
            case let .success(manager):
                self = .initilized(manager)
            }
        }
    }
}
