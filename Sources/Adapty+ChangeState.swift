//
//  Adapty+ChangeState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

public final class Adapty {
    static var shared: Adapty?
    let profileStorage: ProfileStorage
    let apiKeyPrefix: String
    let backend: Backend
    let fallbackBackend: FallbackBackend

    let httpSession: HTTPSession
    let httpFallbackSession: HTTPSession

    let skProductsManager: SKProductsManager
    let sk1ReceiptManager: SK1ReceiptManager
    let _sk2TransactionManager: Any?
    let sk1QueueManager: SK1QueueManager
    let vendorIdsCache: ProductVendorIdsCache
    var onceSentEnvironment: Bool = false
    var state: State

    init(
        apiKeyPrefix: String,
        profileStorage: ProfileStorage,
        vendorIdsStorage: ProductVendorIdsStorage,
        backend: Backend,
        fallbackBackend: FallbackBackend,
        customerUserId: String?
    ) {
        self.apiKeyPrefix = apiKeyPrefix
        self.backend = backend
        self.fallbackBackend = fallbackBackend
        self.profileStorage = profileStorage
        vendorIdsCache = ProductVendorIdsCache(storage: vendorIdsStorage)
        httpSession = backend.createHTTPSession(responseQueue: Adapty.underlayQueue)
        httpFallbackSession = fallbackBackend.createHTTPSession(responseQueue: Adapty.underlayQueue)
        skProductsManager = SKProductsManager(apiKeyPrefix: apiKeyPrefix, storage: UserDefaults.standard, backend: backend)

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            _sk2TransactionManager = SK2TransactionManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, backend: backend)
        } else {
            _sk2TransactionManager = nil
        }

        sk1ReceiptManager = SK1ReceiptManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, backend: backend, refreshIfEmpty: _sk2TransactionManager == nil)

        sk1QueueManager = SK1QueueManager(queue: Adapty.underlayQueue, storage: UserDefaults.standard, skProductsManager: skProductsManager)

        state = .initializingTo(customerUserId: customerUserId)
        sk1QueueManager.startObserving(purchaseValidator: self)
        syncIPv4IfNeed()
        initializingProfileManager(toCustomerUserId: customerUserId)
    }

    private var profileManagerCompletionHandlers: [AdaptyResultCompletion<AdaptyProfileManager>]?
    private var profileManagerOrFailedCompletionHandlers: [AdaptyResultCompletion<AdaptyProfileManager>]?

    private var logoutCompletionHandlers: [AdaptyErrorCompletion]?

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
    private func callProfileManagerCompletionHandlers(_ result: AdaptyResult<AdaptyProfileManager>) {
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
    private func callLogoutCompletionHandlers(_ error: AdaptyError?) {
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
    private func finishLogout() {
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
            if let customerUserId, customerUserId == newCustomerUserId {
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
    private func needBreakInitializing() -> Bool {
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

    private func initializingProfileManager(toCustomerUserId customerUserId: String?) {
        guard !needBreakInitializing() else { return }

        let profileId = profileStorage.profileId

        if let profile = profileStorage.getProfile(profileId: profileId, withCustomerUserId: customerUserId) {
            let manager = AdaptyProfileManager(
                manager: self,
                paywallStorage: UserDefaults.standard,
                productStorage: UserDefaults.standard,
                profile: profile
            )

            state = .initialized(manager)
            callProfileManagerCompletionHandlers(.success(manager))

            if !onceSentEnvironment {
                manager.getProfile { _ in }
            }
            return
        }

        createProfile(profileId, customerUserId) { [weak self] result in
            guard let self, !self.needBreakInitializing() else { return }
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

                let manager = AdaptyProfileManager(
                    manager: self,
                    paywallStorage: UserDefaults.standard,
                    productStorage: UserDefaults.standard,
                    profile: profile
                )

                self.state = .initialized(manager)
                self.callProfileManagerCompletionHandlers(.success(manager))
            }
        }
    }

    private func createProfile(_ profileId: String, _ customerUserId: String?, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        httpSession.performCreateProfileRequest(
            profileId: profileId,
            customerUserId: customerUserId,
            analyticsDisabled: profileStorage.externalAnalyticsDisabled
        ) { [weak self] result in
            guard let self else { return }

            // TODO: Check Cancel

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(profile):
                self.onceSentEnvironment = true

                let storage = self.profileStorage
                if profileId != profile.value.profileId {
                    storage.clearProfile(newProfileId: profile.value.profileId)
                }
                storage.setSyncedTransactions(false)
                storage.setProfile(profile)

                self.syncTransactions(refreshReceiptIfEmpty: false) { result in
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
                false
            default:
                true
            }
        }

        var initialized: AdaptyProfileManager? {
            switch self {
            case let .initialized(manager):
                manager
            default:
                nil
            }
        }

        var initializedResult: AdaptyResult<AdaptyProfileManager>? {
            switch self {
            case let .failed(error):
                .failure(error)
            case let .initialized(manager):
                .success(manager)
            default:
                nil
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
