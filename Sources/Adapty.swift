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
    var sk2Purchaser: SK2Purchaser?
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

        let productVendorIdsStorage = ProductVendorIdsStorage()
        self.variationIdStorage = VariationIdStorage()

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            self.receiptManager = StoreKitReceiptManager(session: httpSession)
            self.transactionManager = SK2TransactionManager(session: httpSession)
            self.productsManager = SK2ProductsManager(apiKeyPrefix: apiKeyPrefix, session: httpSession, storage: productVendorIdsStorage)
            self.sk1QueueManager = nil
        } else {
            self.receiptManager = StoreKitReceiptManager(session: httpSession, refreshIfEmpty: true)
            self.transactionManager = receiptManager
            self.productsManager = SK1ProductsManager(apiKeyPrefix: apiKeyPrefix, session: httpSession, storage: productVendorIdsStorage)
            self.sk1QueueManager = nil
        }

        self.sharedProfileManager = restoreProfileManager(configuration)

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            if !observerMode {
                self.sk2Purchaser = SK2Purchaser.startObserving(
                    purchaseValidator: self,
                    productsManager: productsManager,
                    storage: variationIdStorage
                )

                self.sk1QueueManager = SK1QueueManager.startObserving(
                    purchaseValidator: self,
                    productsManager: productsManager,
                    storage: variationIdStorage
                )
            }
        } else {
            if observerMode {
                SK1TransactionObserver.startObserving(
                    purchaseValidator: self,
                    productsManager: productsManager
                )
            } else {
                self.sk1QueueManager = SK1QueueManager.startObserving(
                    purchaseValidator: self,
                    productsManager: productsManager,
                    storage: variationIdStorage
                )
            }
        }

        startSyncIPv4OnceIfNeeded()
    }

    fileprivate var sharedProfileManager: ProfileManager.Shared?

    private func restoreProfileManager(
        _ configuration: AdaptyConfiguration
    ) -> ProfileManager.Shared {
        if let profile = profileStorage.getProfile(with: configuration.customerUserId) {
            return .current(
                ProfileManager(storage: profileStorage, profile: profile, sentEnvironment: .none)
            )
        } else {
            let newUserId = AdaptyUserId(
                profileId: profileStorage.profileId,
                customerId: configuration.customerUserId
            )
            return .creating(
                userId: newUserId,
                task: Task {
                    try await createNewProfileOnServer(newUserId)
                }
            )
        }
    }

    private func createNewProfileOnServer(
        _ newUserId: AdaptyUserId
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
                        parameters: AdaptyProfileParameters(analyticsDisabled: analyticsDisabled),
                        environmentMeta: meta
                    )
                    createdProfile = response
                }

                var crossPlacementState = CrossPlacementState.defaultForNewUser
                if newUserId.isNotEqualProfileId(response) {
                    crossPlacementState = try await httpSession.fetchCrossPlacementState(
                        userId: response.value.userId
                    )
                }
                return (response, crossPlacementState)
            }.result

            guard case let .creating(creatingUserId, _) = sharedProfileManager, newUserId == creatingUserId else {
                throw .profileWasChanged()
            }

            switch result {
            case let .success((createdProfile, crossPlacementState)):
                if newUserId.isNotEqualProfileId(createdProfile) {
                    profileStorage.clearProfile(newProfile: createdProfile)
                } else {
                    profileStorage.setProfile(createdProfile)
                }

                profileStorage.setSyncedTransactions(false)

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
    func identify(toCustomerUserId newCustomerUserId: String) async throws(AdaptyError) {
        switch sharedProfileManager {
        case .none:
            break
        case let .current(manager):
            guard manager.profile.customerUserId != newCustomerUserId else {
                return
            }
        case let .creating(userId, task):
            guard userId.customerId != newCustomerUserId else {
                _ = try await task.profileManager
                return
            }
            task.cancel()
        }

        let newUserId = AdaptyUserId(
            profileId: profileStorage.profileId,
            customerId: newCustomerUserId
        )
        log.verbose("start identify \(newUserId) ")

        let task = Task { try await createNewProfileOnServer(newUserId) }
        sharedProfileManager = .creating(
            userId: newUserId,
            task: task
        )

        _ = try await task.profileManager
    }

    func logout() async throws(AdaptyError) {
        switch sharedProfileManager {
        case .none:
            break
        case let .current(manager):
            guard manager.userId.isAnonymous else {
                throw AdaptyError.unidentifiedUserLogout()
            }
        case let .creating(userId, task):
            guard userId.isAnonymous else {
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

        let task = Task { try await createNewProfileOnServer(newAnonymousUserId) }
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
            case .none:
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
            case .none:
                throw .profileWasChanged()
            case let .some(value):
                value
            }
        }
    }
}
