//
//  Adapty.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

@AdaptyActor
public final class Adapty: Sendable {
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

        return .creating(
            profileId: profileId,
            withCustomerUserId: customerUserId,
            task: Task {
                try await createNewProfileOnServer(
                    profileId,
                    customerUserId,
                    appAccountToken
                )
            }
        )
    }

    private func createNewProfileOnServer(
        _ profileId: String,
        _ customerUserId: String?,
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
                        profileId: profileId,
                        customerUserId: customerUserId,
                        appAccountToken: appAccountToken,
                        parameters: AdaptyProfileParameters(analyticsDisabled: analyticsDisabled),
                        environmentMeta: meta
                    )
                    createdProfile = response
                }

                var crossPlacementState = CrossPlacementState.defaultForNewUser
                if profileId != response.value.profileId {
                    crossPlacementState = try await httpSession.fetchCrossPlacementState(
                        profileId: response.value.profileId
                    )
                }
                return (response, crossPlacementState)
            }.result

            guard case let .creating(creatingProfileId, creatingCustomerUserId, _) = sharedProfileManager,
                  profileId == creatingProfileId,
                  customerUserId == creatingCustomerUserId
            else {
                throw AdaptyError.profileWasChanged()
            }

            switch result {
            case let .success((createdProfile, crossPlacementState)):
                if profileId != createdProfile.value.profileId {
                    profileStorage.clearProfile(newProfileId: createdProfile.value.profileId)
                }

                profileStorage.setSyncedTransactions(false)
                profileStorage.setProfile(createdProfile)

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
        case .none:
            break

        case let .current(manager):
            if manager.profile.value.customerUserId == newCustomerUserId {
                guard let newAppAccountToken, newAppAccountToken != oldAppAccountToken else {
                    return
                }
            }

        case let .creating(_, customerUserId, task):
            if customerUserId == newCustomerUserId {
                guard let newAppAccountToken, newAppAccountToken != oldAppAccountToken else {
                    _ = try await task.profileManager
                    return
                }
            }

            task.cancel()
        }

        let profileId = profileStorage.profileId

        let task = Task { try await createNewProfileOnServer(profileId, newCustomerUserId, newAppAccountToken) }
        sharedProfileManager = .creating(
            profileId: profileId,
            withCustomerUserId: newCustomerUserId,
            task: task
        )

        _ = try await task.profileManager
    }

    func logout() async throws(AdaptyError) {
        switch sharedProfileManager {
        case .none:
            break
        case let .current(manager):
            if manager.profile.value.customerUserId == nil {
                throw AdaptyError.unidentifiedUserLogout()
            }
        case let .creating(_, customerUserId, task):
            if customerUserId == nil {
                _ = try await task.profileManager
                return
            }
            task.cancel()
        }

        profileStorage.clearProfile(newProfileId: nil)

        let profileId = profileStorage.profileId

        let task = Task { try await createNewProfileOnServer(profileId, nil, nil) }
        sharedProfileManager = .creating(
            profileId: profileId,
            withCustomerUserId: nil,
            task: task
        )
        _ = try await task.profileManager
    }
}

private extension ProfileManager {
    enum Shared {
        case current(ProfileManager)
        case creating(profileId: String, withCustomerUserId: String?, task: Task<ProfileManager, Error>)
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
                throw AdaptyError.profileWasChanged()
            }
        }
    }
}

extension Adapty {
    var customerUserId: String? {
        switch sharedProfileManager {
        case .none:
            return nil
        case let .current(manager):
            return manager.profile.value.customerUserId
        case let .creating(_, customerUserId, _):
            return customerUserId
        }
    }

    var profileManager: ProfileManager? {
        if case let .current(manager) = sharedProfileManager {
            manager
        } else {
            nil
        }
    }

    func profileManager(with profileId: String) throws(AdaptyError) -> ProfileManager? {
        guard let manager = profileManager else { return nil }
        guard profileId == manager.profileId else { throw AdaptyError.profileWasChanged() }
        return manager
    }

    func tryProfileManagerOrNil(with profileId: String) -> ProfileManager? {
        guard let manager = profileManager else { return nil }
        guard profileId == manager.profileId else { return nil }
        return manager
    }

    var createdProfileManager: ProfileManager {
        get async throws(AdaptyError) {
            switch sharedProfileManager {
            case .none:
                throw AdaptyError.notActivated()
            case let .current(manager):
                return manager
            case let .creating(_, _, task):
                do {
                    return try await withTaskCancellationWithError(CancellationError()) {
                        try await task.profileManager
                    }
                } catch {
                    if let adaptyError = error as? AdaptyError {
                        throw adaptyError
                    }
                    throw AdaptyError.profileWasChanged()
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
                throw AdaptyError.profileWasChanged()
            case let .some(value):
                value
            }
        }
    }
}
