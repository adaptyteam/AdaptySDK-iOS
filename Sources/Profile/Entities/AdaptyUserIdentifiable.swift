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
    @inlinable
    var profileId: String { userId.profileId }

    @inlinable
    var customerUserId: String? { userId.customerId }

    @inlinable
    func isEqualProfileId(_ other: String) -> Bool {
        userId.isEqualProfileId(other)
    }

    @inlinable
    func isNotEqualProfileId(_ other: String) -> Bool {
        userId.isNotEqualProfileId(other)
    }

    @inlinable
    func isEqualProfileId(_ other: AdaptyUserId) -> Bool {
        userId.isEqualProfileId(other)
    }

    @inlinable
    func isNotEqualProfileId(_ other: AdaptyUserId) -> Bool {
        userId.isNotEqualProfileId(other)
    }

    @inlinable
    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        userId.isEqualProfileId(other.userId)
    }

    @inlinable
    func isNotEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        userId.isNotEqualProfileId(other.userId)
    }
}

extension AdaptyProfile: AdaptyUserIdentifiable {}

extension VH<AdaptyProfile>: AdaptyUserIdentifiable {
    var userId: AdaptyUserId { value.userId }
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
