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
    let skProductsManager: SKProductsManager
    let skReceiptManager: SKReceiptManager
    let skQueueManager: SKQueueManager
    let vendorIdsCache: ProductVendorIdsCache
    var onceSentEnvironment: Bool = false
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
        skReceiptManager = SKReceiptManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, backend: backend)
        skQueueManager = SKQueueManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, skProductsManager: skProductsManager)

        state = .initializingTo(customerUserId: customerUserId)

        skReceiptManager.refreshReceiptIfEmpty()
        skQueueManager.startObserving(purchaseValidator: self)
        initializingProfileManager(toCustomerUserId: customerUserId)
    }

    fileprivate var profileManagerCompletionHandlers: [AdaptyResultCompletion<AdaptyProfileManager>]?
    fileprivate var profileManagerOrFailedCompletionHandlers: [AdaptyResultCompletion<AdaptyProfileManager>]?

    fileprivate var logoutCompletionHandlers: [AdaptyErrorCompletion]?

    @inline(__always)
    func getProfileManager(waitCreatingProfile: Bool = true, _ completion: @escaping AdaptyResultCompletion<AdaptyProfileManager>) {
        if let result = state.initializedResult {
            completion(result)
            return
        }

        if waitCreatingProfile {
            if let handlers = profileManagerCompletionHandlers {
                profileManagerCompletionHandlers = handlers + [completion]
                return
            }
            profileManagerCompletionHandlers = [completion]
        } else {
            if let handlers = profileManagerOrFailedCompletionHandlers {
                profileManagerOrFailedCompletionHandlers = handlers + [completion]
                return
            }
            profileManagerOrFailedCompletionHandlers = [completion]
        }
    }

    @inline(__always)
    fileprivate func callProfileManagerCompletionHandlers(_ result: AdaptyResult<AdaptyProfileManager>) {
        let handlers: [AdaptyResultCompletion<AdaptyProfileManager>]
        if let error = result.error, error.isProfileCreateFailed {
            handlers = profileManagerOrFailedCompletionHandlers ?? []
            profileManagerOrFailedCompletionHandlers = nil
        } else {
            handlers = (profileManagerCompletionHandlers ?? []) + (profileManagerOrFailedCompletionHandlers ?? [])
            profileManagerCompletionHandlers = nil
            profileManagerOrFailedCompletionHandlers = nil
        }
        guard !handlers.isEmpty else { return }

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
        case let .initialized(manager):
            manager.isActive = false
            finishLogout()
        case .initializingTo,
             .needIdentifyTo,
             .needLogout:
            state = .needLogout
        }
    }

    @inline(__always)
    fileprivate func finishLogout() {
        profileStorage.clearProfile(newProfileId: nil)
        state = .initializingTo(customerUserId: nil)
        callLogoutCompletionHandlers(nil)
        callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
        Adapty.underlayQueue.async { [weak self] in
            self?.initializingProfileManager(toCustomerUserId: nil)
        }
    }

    @inline(__always)
    func identify(toCustomerUserId newCustomerUserId: String, _ completion: @escaping AdaptyErrorCompletion) {
        switch state {
        case let .failed(error):
            completion(error)
            return
        case let .initialized(manager):
            guard manager.profile.value.customerUserId != newCustomerUserId else {
                completion(nil)
                return
            }
            manager.isActive = false
            state = .initializingTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
            Adapty.underlayQueue.async { [weak self] in
                self?.initializingProfileManager(toCustomerUserId: newCustomerUserId)
            }
            return
        case let .initializingTo(customerUserId):
            if let customerUserId = customerUserId, customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case let .needIdentifyTo(customerUserId):
            if customerUserId == newCustomerUserId {
                getProfileManager { completion($0.error) }
                return
            }
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
//            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        case .needLogout:
            profileStorage.clearProfile(newProfileId: nil)
            state = .needIdentifyTo(customerUserId: newCustomerUserId)
            callLogoutCompletionHandlers(nil)
            callProfileManagerCompletionHandlers(.failure(.profileWasChanged()))
            getProfileManager { completion($0.error) }
        }
    }

    @inline(__always)
    fileprivate func needBreakInitializing() -> Bool {
        switch state {
        case .initializingTo:
            return false
        case .failed, .initialized:
            return true
        case .needLogout:
            finishLogout()
            return true
        case let .needIdentifyTo(customerUserId):
            state = .initializingTo(customerUserId: customerUserId)
            Adapty.underlayQueue.async { [weak self] in
                self?.initializingProfileManager(toCustomerUserId: customerUserId)
            }
            return true
        }
    }

    fileprivate func initializingProfileManager(toCustomerUserId customerUserId: String?) {
        guard !needBreakInitializing() else { return }

        let profileId = profileStorage.profileId

        if let profile = profileStorage.getProfile(profileId: profileId, withCustomerUserId: customerUserId) {
            let manager = AdaptyProfileManager(manager: self,
                                               paywallStorage: UserDefaults.standard,
                                               productStorage: UserDefaults.standard,
                                               profile: profile)

            state = .initialized(manager)
            callProfileManagerCompletionHandlers(.success(manager))

            if !onceSentEnvironment {
                manager.getProfile { _ in }
            }
            return
        }

        createProfile(profileId, customerUserId) { [weak self] result in
            guard let self = self, !self.needBreakInitializing() else { return }
            switch result {
            case let .failure(error):
                if let error = error.wrapped as? HTTPError {
                    self.callProfileManagerCompletionHandlers(.failure(.profileCreateFailed(error)))
                }
                // TODO: Dont repeat if wrong apiKey, and ???
                Adapty.underlayQueue.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.initializingProfileManager(toCustomerUserId: customerUserId)
                }
            case let .success(profile):

                let manager = AdaptyProfileManager(manager: self,
                                                   paywallStorage: UserDefaults.standard,
                                                   productStorage: UserDefaults.standard,
                                                   profile: profile)

                self.state = .initialized(manager)
                self.callProfileManagerCompletionHandlers(.success(manager))
            }
        }
    }

    fileprivate func createProfile(_ profileId: String, _ customerUserId: String?, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        httpSession.performCreateProfileRequest(profileId: profileId,
                                                customerUserId: customerUserId,
                                                analyticsDisabled: profileStorage.externalAnalyticsDisabled) { [weak self] result in
            guard let self = self else { return }

            // TODO: Check Cancel

            switch result {
            case let .failure(error):
                completion(.failure(error))
                break
            case let .success(profile):
                self.onceSentEnvironment = true

                let storage = self.profileStorage
                if profileId != profile.value.profileId {
                    storage.clearProfile(newProfileId: profile.value.profileId)
                }
                storage.setProfile(profile)

                self.validateReceipt(refreshIfEmpty: false) { result in
                    completion(.success((try? result.get()) ?? profile))
                }
            }
        }
    }

    enum State {
        case initializingTo(customerUserId: String?)
        case needLogout
        case needIdentifyTo(customerUserId: String)
        case failed(AdaptyError)
        case initialized(AdaptyProfileManager)

        var initializing: Bool {
            switch self {
            case .failed, .initialized:
                return false
            default:
                return true
            }
        }

        var initialized: AdaptyProfileManager? {
            switch self {
            case let .initialized(manager):
                return manager
            default:
                return nil
            }
        }

        var initializedResult: AdaptyResult<AdaptyProfileManager>? {
            switch self {
            case let .failed(error):
                return .failure(error)
            case let .initialized(manager):
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
                self = .initialized(manager)
            }
        }
    }
}
