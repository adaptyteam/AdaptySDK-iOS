//
//  Adapty+OLD.swift
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

        #if compiler(>=5.10)
            let productVendorIdsStorage = ProductVendorIdsStorage()
        #else
            let productVendorIdsStorage = await ProductVendorIdsStorage()
        #endif

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

        self.sharedProfileManager = restoreProfileManager(
            profileId: profileStorage.profileId,
            customerUserId: configuration.customerUserId
        )

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            if !observerMode {
                #if compiler(>=5.10)
                    let variationIdStorage = VariationIdStorage()
                #else
                    let variationIdStorage = await VariationIdStorage()
                #endif

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
                #if compiler(>=5.10)
                    let variationIdStorage = VariationIdStorage()
                #else
                    let variationIdStorage = await VariationIdStorage()
                #endif
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
        profileId: String,
        customerUserId: String?
    ) -> ProfileManager.Shared {
        if let profile = profileStorage.getProfile(
            profileId: profileId,
            withCustomerUserId: customerUserId
        ) {
            .current(
                ProfileManager(storage: profileStorage, profile: profile, sendedEnvironment: .dont)
            )
        } else {
            .creating(
                profileId: profileId,
                withCustomerUserId: customerUserId,
                task: Task {
                    try await createNewProfileOnServer(profileId, customerUserId)
                }
            )
        }
    }

    private func createNewProfileOnServer(
        _ profileId: String,
        _ customerUserId: String?
    ) async throws -> ProfileManager {
        var isFerstLoop = true

        let analyticsDisabled = profileStorage.externalAnalyticsDisabled
        var createdProfile: VH<AdaptyProfile>?
        while true {
            let meta = await Environment.Meta(includedAnalyticIds: !analyticsDisabled)

            let result = await Task {
                if isFerstLoop {
                    isFerstLoop = false
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
                        parameters: AdaptyProfileParameters(analyticsDisabled: analyticsDisabled),
                        environmentMeta: meta
                    )
                    createdProfile = response
                }

                guard profileId != response.value.profileId else {
                    return (response, CrossPlacementState.defaultForNewUser)
                }

                let newProfileId = response.value.profileId
                let crossPlacementState = try await httpSession.fetchCrossPlacementState(profileId: newProfileId)

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

                Log.crossAB.verbose("createProfile version = \(crossPlacementState.version), value = \(crossPlacementState.variationIdByPlacements)")

                profileStorage.setCrossPlacementState(crossPlacementState)

                let manager = ProfileManager(
                    storage: profileStorage,
                    profile: createdProfile,
                    sendedEnvironment: meta.sendedEnvironment
                )
                sharedProfileManager = .current(manager)
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
    func identify(toCustomerUserId newCustomerUserId: String) async throws {
        let profileId: String
        switch sharedProfileManager {
        case .none:
            profileId = profileStorage.profileId
        case let .current(manager):
            guard manager.profile.value.customerUserId != newCustomerUserId else {
                return
            }
            profileId = manager.profileId
        case let .creating(id, customerUserId, task):
            guard customerUserId != newCustomerUserId else {
                _ = try await task.value
                return
            }
            profileId = id
            task.cancel()
        }

        let task = Task { try await createNewProfileOnServer(profileId, newCustomerUserId) }
        sharedProfileManager = .creating(
            profileId: profileId,
            withCustomerUserId: newCustomerUserId,
            task: task
        )

        _ = try await task.value
    }

    func logout() async throws {
        if case let .creating(_, _, task) = sharedProfileManager {
            task.cancel()
        }

        profileStorage.clearProfile(newProfileId: nil)

        let profileId = profileStorage.profileId

        let task = Task { try await createNewProfileOnServer(profileId, nil) }
        sharedProfileManager = .creating(
            profileId: profileId,
            withCustomerUserId: nil,
            task: task
        )

        _ = try await task.value
    }
}

private extension ProfileManager {
    enum Shared {
        case current(ProfileManager)
        case creating(profileId: String, withCustomerUserId: String?, task: Task<ProfileManager, Error>)
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

    func profileManager(with profileId: String) throws -> ProfileManager? {
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
        get async throws {
            switch sharedProfileManager {
            case .none:
                throw AdaptyError.notActivated()
            case let .current(manager):
                return manager
            case let .creating(_, _, task):
                return try await withTaskCancellationWithError(CancellationError()) {
                    do {
                        return try await task.value
                    } catch is CancellationError {
                        throw AdaptyError.profileWasChanged()
                    } catch {
                        throw error
                    }
                }
            }
        }
    }
}

extension ProfileManager? {
    var orThrows: ProfileManager {
        get throws {
            switch self {
            case .none:
                throw AdaptyError.profileWasChanged()
            case let .some(value):
                value
            }
        }
    }
}
