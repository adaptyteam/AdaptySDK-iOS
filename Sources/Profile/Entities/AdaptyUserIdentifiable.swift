//
//  AdaptyUserIdentifiable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

protocol AdaptyUserIdentifiable {
    var userId: AdaptyUserId { get }
}

extension AdaptyUserId {
    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        isEqualProfileId(other.userId)
    }

    func isNotEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        !isEqualProfileId(other.userId)
    }
}

extension AdaptyUserIdentifiable {
    var profileId: String { userId.profileId }

    var customerUserId: String? { userId.customerId }

    func isEqualProfileId(_ other: AdaptyUserId) -> Bool {
        userId.isEqualProfileId(other)
    }

    func isNotEqualProfileId(_ other: AdaptyUserId) -> Bool {
        !userId.isEqualProfileId(other)
    }

    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        userId.isEqualProfileId(other.userId)
    }

    func isNotEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        !userId.isEqualProfileId(other.userId)
    }
}

extension ProfileStorage {
    var profileId: String {
        userId.profileId
    }
}

extension ProfileManager {
    func isEqualProfileId(_ other: AdaptyUserId) -> Bool {
        userId.isEqualProfileId(other)
    }
    
    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        userId.isEqualProfileId(other.userId)
    }
}

extension AdaptyProfile: AdaptyUserIdentifiable {}

extension VH<AdaptyProfile>: AdaptyUserIdentifiable {
    var userId: AdaptyUserId { value.userId }
}
