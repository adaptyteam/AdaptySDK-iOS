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

    let httpSession: HTTPSession
    let httpFallbackSession: HTTPSession
    let httpConfigsSession: HTTPSession

    init(
        apiKeyPrefix: String,
        profileStorage: ProfileStorage,
        backend: Backend,
        customerUserId _: String?
    ) {
        self.apiKeyPrefix = apiKeyPrefix
        self.backend = backend
        self.profileStorage = profileStorage
        httpSession = backend.createHTTPSession()
        httpFallbackSession = backend.fallback.createHTTPSession()
        httpConfigsSession = backend.configs.createHTTPSession()
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
    
    var createdProfileManagerOrThrows: ProfileManager {
        get async throws {
            profile
        }
    }
    

    var profileManagerOrNil: ProfileManager? {
        nil
    }
}

extension TimeInterval {
    static let defaultLoadPaywallTimeout: TimeInterval = 5.0
}
