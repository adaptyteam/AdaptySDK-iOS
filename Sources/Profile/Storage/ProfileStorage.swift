//
//  ProfileStorage.swift
//  AdaptySDK
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProfileIdentifierStorage {
    var profileId: String { get }
}

protocol ProfileStorage: ProfileIdentifierStorage {
    func getProfile() -> VH<AdaptyProfile>?
    func setProfile(_: VH<AdaptyProfile>)

    var externalAnalyticsDisabled: Bool { get }
    var syncedTransactions: Bool { get }

    func setSyncedTransactions(_: Bool)
    func setExternalAnalyticsDisabled(_: Bool)

    var appleSearchAdsSyncDate: Date? { get }
    func setAppleSearchAdsSyncDate()

    func clearProfile(newProfileId: String?)
}

extension ProfileStorage {
    func getProfile(profileId: String, withCustomerUserId newCustomerUserId: String?) -> VH<AdaptyProfile>? {
        guard let profile = getProfile() else { return nil }
        guard profile.value.profileId == profileId else { return nil }
        guard let newCustomerUserId else { return profile }
        guard let oldCustomerUserId = profile.value.customerUserId else { return nil }
        guard oldCustomerUserId == newCustomerUserId else { return nil }
        return profile
    }
}
