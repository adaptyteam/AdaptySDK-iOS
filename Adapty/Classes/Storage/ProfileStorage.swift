//
//  ProfileStorage.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProfileStorage {
    var profileId: String { get }
    func getProfile() -> VH<Profile>?
    func setProfile(_: VH<Profile>)

    var externalAnalyticsDisabled: Bool { get }
    var syncedBundleReceipt: Bool { get }

    func setSyncedBundleReceipt()
    func setExternalAnalyticsDisabled(_ value: Bool)

    var appleSearchAdsSyncDate: Date? { get }
    func setAppleSearchAdsSyncDate()

    func clearProfile(newProfileId: String?)
}

extension ProfileStorage {
    func getProfile(profileId: String, withCustomerUserId newCustomerUserId: String?) -> VH<Profile>? {
        guard let profile = getProfile() else { return nil }
        guard profile.value.profileId == profileId else { return nil }
        guard let newCustomerUserId = newCustomerUserId else { return profile }
        guard let oldCustomerUserId = profile.value.customerUserId else { return nil }
        guard oldCustomerUserId == newCustomerUserId else { return nil }
        return profile
    }
}
