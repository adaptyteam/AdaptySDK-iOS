//
//  Adapty.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

private let log = Log.default

@AdaptyActor
public final class Adapty {
    let profileStorage: ProfileStorage

    let apiKeyPrefix: String

    let backend: Backend
    let httpSession: Backend.MainExecutor
    let httpFallbackSession: Backend.FallbackExecutor
    let httpConfigsSession: Backend.ConfigsExecutor

    let receiptManager: StoreKitReceiptManager
    let transactionManager: StoreKitTransactionManager
    let productsManager: StoreKitProductsManager
    var purchaser: StorekitPurchaser?
    var sk1QueueManager: SK1QueueManager?

    package let observerMode: Bool

    let variationIdStorage: VariationIdStorage

    init(
        configuration: AdaptyConfiguration,
        backend: Backend
    ) async {
        self.observerMode = configuration.observerMode
        self.apiKeyPrefix = String(configuration.apiKey.prefix(while: { $0 != "." }))
        self.backend = backend
        self.profileStorage = ProfileStorage()
        self.httpSession = backend.createMainExecutor()
        self.httpFallbackSession = backend.createFallbackExecutor()
        self.httpConfigsSession = backend.createConfigsExecutor()

        let productVendorIdsStorage = BackendProductInfoStorage()
        self.variationIdStorage = VariationIdStorage()

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            self.receiptManager = StoreKitReceiptManager(session: httpSession, refreshIfEmpty: false)
            self.transactionManager = SK2TransactionManager(session: httpSession)
            let sk2ProductsManager = SK2ProductsManager(apiKeyPrefix: apiKeyPrefix, session: httpSession, storage: productVendorIdsStorage)
            self.productsManager = sk2ProductsManager

            self.sharedProfileManager = restoreProfileManager(configuration)

            if !observerMode {
                self.purchaser = SK2Purchaser.startObserving(
                    purchaseValidator: self,
                    sk2ProductsManager: sk2ProductsManager,
                    storage: variationIdStorage
                )

                self.sk1QueueManager = SK1QueueManager.startObserving(
                    purchaseValidator: self,
                    productsManager: sk2ProductsManager,
                    storage: variationIdStorage
                )
            }

        } else {
            self.receiptManager = StoreKitReceiptManager(session: httpSession, refreshIfEmpty: true)
            self.transactionManager = receiptManager
            let sk1ProductsManager = SK1ProductsManager(apiKeyPrefix: apiKeyPrefix, session: httpSession, storage: productVendorIdsStorage)
            self.productsManager = sk1ProductsManager

            self.sharedProfileManager = restoreProfileManager(configuration)

            if observerMode {
                SK1TransactionObserver.startObserving(
                    purchaseValidator: self,
                    sk1ProductsManager: sk1ProductsManager
                )
            } else {
                self.sk1QueueManager = SK1QueueManager.startObserving(
                    purchaseValidator: self,
                    productsManager: sk1ProductsManager,
                    storage: variationIdStorage
                )
                self.purchaser = sk1QueueManager
            }
        }
        startSyncIPv4OnceIfNeeded()
    }

    fileprivate var sharedProfileManager: ProfileManager.Shared?

    private func restoreProfileManager(
        _ configuration: AdaptyConfiguration
    ) -> ProfileManager.Shared {
        let profileId = profileStorage.profileId
        let customerUserId = configuration.customerUserId
        let appAccountToken = customerUserId != nil ? configuration.appAccountToken : nil
        let oldAppAccountToken = profileStorage.getAppAccountToken()
        profileStorage.setAppAccountToken(appAccountToken)

        if let profile = profileStorage.getProfile(withCustomerUserId: customerUserId) {
            guard let appAccountToken, appAccountToken != oldAppAccountToken else {
                return .current(.init(
                    storage: profileStorage,
                    profile: profile,
                    sentEnvironment: .none
                ))
            }
        }

        let newUserId = AdaptyUserId(
            profileId: profileId,
            customerId: customerUserId
        )
        return .creating(
            userId: newUserId,
            task: Task {
                try await createNewProfileOnServer(
                    newUserId,
                    appAccountToken
                )
            }
        )
    }

    private func createNewProfileOnServer(
        _ newUserId: AdaptyUserId,
        _ appAccountToken: UUID?
    ) async throws(AdaptyError) -> ProfileManager {
        var isFirstLoop = true

        let analyticsDisabled = profileStorage.externalAnalyticsDisabled
        var createdProfile: VH<AdaptyProfile>?
        while true {
            let meta = await Environment.Meta(includedAnalyticIds: !analyticsDisabled)

            let result = await Task {
                if isFirstLoop {
                    isFirstLoop = false
                } else {
                    try await Task.sleep(duration: .milliseconds(100))
                }

                let response: VH<AdaptyProfile>
                if let createdProfile {
                    response = createdProfile
                } else {
                    response = try await httpSession.createProfile(
                        userId: newUserId,
                        appAccountToken: appAccountToken,
                        parameters: AdaptyProfileParameters(analyticsDisabled: analyticsDisabled),
                        environmentMeta: meta
                    )
                    createdProfile = response
                }

                var crossPlacementState = CrossPlacementState.defaultForNewUser
                if newUserId.isNotEqualProfileId(response) {
                    crossPlacementState = try await httpSession.fetchCrossPlacementState(
                        userId: response.userId
                    )
                }
                return (response, crossPlacementState)
            }.result

            guard case let .creating(creatingUserId, _) = sharedProfileManager, newUserId == creatingUserId else {
                throw .profileWasChanged()
            }

            switch result {
            case let .success((createdProfile, crossPlacementState)):
                if newUserId.isNotEqualProfileId(createdProfile)  {
                    profileStorage.clearProfile(newProfile: createdProfile)
                } else {
                    profileStorage.setProfile(createdProfile)
                    profileStorage.setSyncedTransactionsHistory(false)
                }

                let manager = ProfileManager(
                    storage: profileStorage,
                    profile: createdProfile,
                    sentEnvironment: meta.sentEnvironment
                )
                sharedProfileManager = .current(manager)
                manager.saveCrossPlacementState(crossPlacementState)
                return manager

            case .failure:
                // TODO: ???
                // if let error = error.wrapped as? HTTPError {
                //     self.callProfileManagerCompletionHandlers(.failure(.profileCreateFailed(error)))
                // }
                // TODO: is wrong api key - return error
                continue
            }
        }
    }
}

extension Adapty {
    func identify(
        toCustomerUserId newCustomerUserId: String,
        withAppAccountToken newAppAccountToken: UUID?
    ) async throws(AdaptyError) {
        let oldAppAccountToken = profileStorage.getAppAccountToken()
        profileStorage.setAppAccountToken(newAppAccountToken)

        switch sharedProfileManager {
        case nil:
            break
        case let .current(manager):
            if manager.userId.customerId == newCustomerUserId {
                guard let newAppAccountToken, newAppAccountToken != oldAppAccountToken else {
                    return
                }
            }
        case let .creating(userId, task):
            if userId.customerId == newCustomerUserId {
                guard let newAppAccountToken, newAppAccountToken != oldAppAccountToken else {
                    _ = try await task.profileManager
                    return
                }
            }
            task.cancel()
        }

        let newUserId = AdaptyUserId(
            profileId: profileStorage.profileId,
            customerId: newCustomerUserId
        )
        log.verbose("start identify \(newUserId) ")

        let task = Task { try await createNewProfileOnServer(newUserId, newAppAccountToken) }
        sharedProfileManager = .creating(
            userId: newUserId,
            task: task
        )

        _ = try await task.profileManager
    }

    func logout() async throws(AdaptyError) {
        switch sharedProfileManager {
        case nil:
            break
        case let .current(manager):
            if manager.userId.isAnonymous {
                throw .unidentifiedUserLogout()
            }
        case let .creating(userId, task):
            if userId.isAnonymous {
                _ = try await task.profileManager
                return
            }
            task.cancel()
        }

        profileStorage.clearProfile()

        let newAnonymousUserId = AdaptyUserId(
            profileId: profileStorage.profileId,
            customerId: nil
        )

        log.verbose("logout \(newAnonymousUserId) ")

        let task = Task { try await createNewProfileOnServer(newAnonymousUserId, nil) }
        sharedProfileManager = .creating(
            userId: newAnonymousUserId,
            task: task
        )
        _ = try await task.profileManager
    }
}

private extension ProfileManager {
    enum Shared {
        case current(ProfileManager)
        case creating(userId: AdaptyUserId, task: Task<ProfileManager, Error>)
    }
}

private extension Task where Success == ProfileManager {
    var profileManager: ProfileManager {
        get async throws(AdaptyError) {
            do {
                return try await value
            } catch {
                if let adaptyError = error as? AdaptyError {
                    throw adaptyError
                }
                throw .profileWasChanged()
            }
        }
    }
}

extension Adapty {
    var userId: AdaptyUserId? {
        switch sharedProfileManager {
        case nil:
            return nil
        case let .current(manager):
            return manager.userId
        case let .creating(userId, _):
            return userId
        }
    }

    var profileManager: ProfileManager? {
        if case let .current(manager) = sharedProfileManager {
            manager
        } else {
            nil
        }
    }

    func profileManager(withProfileId userId: AdaptyUserId) throws(AdaptyError) -> ProfileManager? {
        guard let manager = profileManager else { return nil }
        guard manager.isEqualProfileId(userId) else { throw .profileWasChanged() }
        return manager
    }

    var createdProfileManager: ProfileManager {
        get async throws(AdaptyError) {
            switch sharedProfileManager {
            case nil:
                throw .notActivated()
            case let .current(manager):
                return manager
            case let .creating(_, task):
                do {
                    return try await withTaskCancellationWithError(CancellationError()) {
                        try await task.profileManager
                    }
                } catch {
                    if let adaptyError = error as? AdaptyError {
                        throw adaptyError
                    }
                    throw .profileWasChanged()
                }
            }
        }
    }
}

extension ProfileManager? {
    var orThrows: ProfileManager {
        get throws(AdaptyError) {
            switch self {
            case nil:
                throw .profileWasChanged()
            case let value?:
                value
            }
        }
    }
}
