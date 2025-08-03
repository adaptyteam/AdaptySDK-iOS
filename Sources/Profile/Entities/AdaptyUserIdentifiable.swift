//
//  AdaptyUserIdentifiable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

protocol AdaptyUserIdentifiable {
    @AdaptyActor
    var userId: AdaptyUserId { get }
}

extension AdaptyUserId {
    @AdaptyActor
    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        isEqualProfileId(other.userId)
    }

    @AdaptyActor
    func isNotEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        !isEqualProfileId(other.userId)
    }
}

extension AdaptyUserIdentifiable {
    @AdaptyActor
    var profileId: String { userId.profileId }

    @AdaptyActor
    var customerUserId: String? { userId.customerId }

    @AdaptyActor
    func isEqualProfileId(_ other: AdaptyUserId) -> Bool {
        userId.isEqualProfileId(other)
    }

    @AdaptyActor
    func isNotEqualProfileId(_ other: AdaptyUserId) -> Bool {
        !userId.isEqualProfileId(other)
    }

    @AdaptyActor
    func isEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        userId.isEqualProfileId(other.userId)
    }

    @AdaptyActor
    func isNotEqualProfileId(_ other: AdaptyUserIdentifiable) -> Bool {
        !userId.isEqualProfileId(other.userId)
    }
}

extension AdaptyProfile: AdaptyUserIdentifiable {}
extension ProfileStorage: AdaptyUserIdentifiable {}
extension ProfileManager: AdaptyUserIdentifiable {}
extension VH<AdaptyProfile>: AdaptyUserIdentifiable {
    var userId: AdaptyUserId { value.userId }
}
