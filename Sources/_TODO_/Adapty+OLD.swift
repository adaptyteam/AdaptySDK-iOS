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
    }

    func syncTransactions(refreshReceiptIfEmpty _: Bool) async throws -> VH<AdaptyProfile>? {
        throw AdaptyError.cantMakePayments()
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
