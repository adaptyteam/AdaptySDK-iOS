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

    var profileManager: ProfileManager?

    let backend: Backend
    let httpSession: Backend.MainExecutor
    let httpFallbackSession: Backend.FallbackExecutor
    let httpConfigsSession: Backend.ConfigsExecutor

    let receiptManager: StoreKitReceiptManager
    let transactionManager: StoreKitTransactionManager
    let sk2ProductsManager: SK2ProductsManager
    
    
    init(
        apiKeyPrefix: String,
        profileStorage: ProfileStorage,
        backend: Backend,
        customerUserId _: String?
    ) {
        self.apiKeyPrefix = apiKeyPrefix
        self.backend = backend
        self.profileStorage = profileStorage
        httpSession = backend.createMainExecutor()
        httpFallbackSession = backend.createFallbackExecutor()
        httpConfigsSession = backend.createConfigsExecutor()

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            receiptManager = StoreKitReceiptManager(session: httpSession)
            transactionManager = SK2TransactionManager(session: httpSession)
        } else {
            receiptManager = StoreKitReceiptManager(session: httpSession, refreshIfEmpty: true)
            transactionManager = receiptManager
        }
    }

    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
    }

    nonisolated(unsafe) static var share: Adapty!

    static var sdk: Adapty {
        get throws {
            guard let share = Adapty.share else {
                throw AdaptyError.notActivated()
            }
            return share
        }
    }

    nonisolated(unsafe) var profile: ProfileManager!

    var createdProfileManager: ProfileManager {
        get async throws {
            profile
        }
    }
}

extension Adapty {
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
