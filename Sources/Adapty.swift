//
//  Adapty+OLD.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

@AdaptyActor
public final class Adapty: Sendable {
    static let profileIdentifierStorage: ProfileIdentifierStorage = UserDefaults.standard
    let profileStorage: ProfileStorage

    let apiKeyPrefix: String

    let backend: Backend
    let httpSession: Backend.MainExecutor
    let httpFallbackSession: Backend.FallbackExecutor
    let httpConfigsSession: Backend.ConfigsExecutor

    let receiptManager: StoreKitReceiptManager
    let transactionManager: StoreKitTransactionManager
    let productsManager: StoreKitProductsManager
    var sk1QueueManager: SK1QueueManager?

    package let observerMode: Bool

    init(
        configuration: Configuration,
        profileStorage: ProfileStorage,
        backend: Backend
    ) async {
        self.observerMode = configuration.observerMode
        self.apiKeyPrefix = String(configuration.apiKey.prefix(while: { $0 != "." }))
        self.backend = backend
        self.profileStorage = profileStorage
        self.httpSession = backend.createMainExecutor()
        self.httpFallbackSession = backend.createFallbackExecutor()
        self.httpConfigsSession = backend.createConfigsExecutor()

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            self.receiptManager = StoreKitReceiptManager(session: httpSession)
            self.transactionManager = SK2TransactionManager(session: httpSession)
            self.productsManager = SK2ProductsManager(apiKeyPrefix: apiKeyPrefix, storage: UserDefaults.standard, session: httpSession)
            self.sk1QueueManager = nil
        } else {
            self.receiptManager = StoreKitReceiptManager(session: httpSession, refreshIfEmpty: true)
            self.transactionManager = receiptManager
            self.productsManager = SK1ProductsManager(apiKeyPrefix: apiKeyPrefix, storage: UserDefaults.standard, session: httpSession)
            self.sk1QueueManager = nil
        }

        self.sharedProfileManager = restoreProfileManager(
            profileId: profileStorage.profileId,
            customerUserId: configuration.customerUserId
        )

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            if observerMode {
                SK2TransactionObserver.startObserving(purchaseValidator: self, productsManager: productsManager)
            }
        } else {
            if observerMode {
                SK1TransactionObserver.startObserving(purchaseValidator: self, productsManager: productsManager)
                self.sk1QueueManager = nil
            } else {
                self.sk1QueueManager = observerMode ? nil : SK1QueueManager.startObserving(purchaseValidator: self, productsManager: productsManager)
            }
        }
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
        while true {
            let meta = await Environment.Meta(includedAnalyticIds: !analyticsDisabled)

            let result = await Task {
                if isFerstLoop {
                    isFerstLoop = false
                } else {
                    try await Task.sleep(duration: .milliseconds(100))
                }
                return try await httpSession.createProfile(
                    profileId: profileId,
                    customerUserId: customerUserId,
                    parameters: AdaptyProfileParameters(analyticsDisabled: analyticsDisabled),
                    environmentMeta: meta
                )
            }.result

            guard case let .creating(creatingProfileId, creatingCustomerUserId, _) = sharedProfileManager,
                  profileId == creatingProfileId,
                  customerUserId == creatingCustomerUserId
            else {
                throw AdaptyError.profileWasChanged()
            }

            switch result {
            case let .success(createdProfile):

                if profileId != createdProfile.value.profileId {
                    profileStorage.clearProfile(newProfileId: createdProfile.value.profileId)
                }
                profileStorage.setSyncedTransactions(false)
                profileStorage.setProfile(createdProfile)

                let manager = ProfileManager(
                    storage: profileStorage,
                    profile: createdProfile,
                    sendedEnvironment: meta.sendedEnvironment
                )
                self.sharedProfileManager = .current(manager)
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
        switch sharedProfileManager {
        case .none:
            break
        case let .current(manager):
            guard manager.profile.value.customerUserId != newCustomerUserId else {
                return
            }
        case let .creating(_, customerUserId, task):
            guard customerUserId != newCustomerUserId else {
                _ = try await task.value
                return
            }

            task.cancel()
        }
        try await logoutAndCreateNewProfileOnServer(customerUserId: newCustomerUserId)
    }

    func logout() async throws {
        if case let .creating(_, _, task) = sharedProfileManager {
            task.cancel()
        }
        return try await logoutAndCreateNewProfileOnServer()
    }

    private func logoutAndCreateNewProfileOnServer(customerUserId: String? = nil) async throws {
        profileStorage.clearProfile(newProfileId: nil)
        let profileId = profileStorage.profileId

        let task = Task { try await createNewProfileOnServer(profileId, customerUserId) }
        self.sharedProfileManager = .creating(
            profileId: profileId,
            withCustomerUserId: customerUserId,
            task: task
        )

        _ = try await task.value
    }
}

private extension ProfileManager {
    convenience init(
        storage: ProfileStorage,
        profile: VH<AdaptyProfile>,
        sendedEnvironment: ProfileManager.SendedEnvironment
    ) {
        self.init(
            storage: storage,
            paywallStorage: UserDefaults.standard,
            productStorage: UserDefaults.standard,
            profile: profile,
            sendedEnvironment: sendedEnvironment
        )
    }

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
                throw AdaptyError.profileWasChanged()
            case let .current(manager):
                return manager
            case let .creating(_, _, task):
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
