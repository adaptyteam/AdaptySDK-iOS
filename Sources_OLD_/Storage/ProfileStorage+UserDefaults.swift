//
//  ProfileStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

extension UserDefaults: ProfileStorage {
    fileprivate enum Constants {
        static let profileKey = "AdaptySDK_Purchaser_Info"
        static let profileIdKey = "AdaptySDK_Profile_Id"
        static let externalAnalyticsDisabledKey = "AdaptySDK_External_Analytics_Disabled"
        static let syncedTransactionsKey = "AdaptySDK_Synced_Bundle_Receipt"
        static let appleSearchAdsSyncDateKey = "AdaptySDK_Apple_Search_Ads_Sync_Date"
    }

    var profileId: String {
        if let identifier = string(forKey: Constants.profileIdKey) {
            return identifier
        }

        let identifier = UUID().uuidString.lowercased()
        log.debug("create profileId = \(identifier)")
        set(identifier, forKey: Constants.profileIdKey)
        return identifier
    }

    var externalAnalyticsDisabled: Bool {
        bool(forKey: Constants.externalAnalyticsDisabledKey)
    }

    func setExternalAnalyticsDisabled(_ value: Bool) {
        log.debug("set externalAnalyticsDisabled = \(value).")
        set(value, forKey: Constants.externalAnalyticsDisabledKey)
    }

    func getProfile() -> VH<AdaptyProfile>? {
        do {
            return try getJSON(VH<AdaptyProfile>.self, forKey: Constants.profileKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }

    var syncedTransactions: Bool {
        bool(forKey: Constants.syncedTransactionsKey)
    }

    func setSyncedTransactions(_ value: Bool) {
        log.debug("set syncedBundleReceipt = \(value).")
        set(value, forKey: Constants.syncedTransactionsKey)
    }

    var appleSearchAdsSyncDate: Date? {
        object(forKey: Constants.appleSearchAdsSyncDateKey) as? Date
    }

    func setAppleSearchAdsSyncDate() {
        let date = Date()
        log.debug("set appleSearchAdsSyncDate = \(date).")
        set(date, forKey: Constants.appleSearchAdsSyncDateKey)
    }

    func setProfile(_ profile: VH<AdaptyProfile>) {
        do {
            try setJSON(profile, forKey: Constants.profileKey)
            log.debug("saving profile success.")
        } catch {
            log.error("saving profile fail. \(error.localizedDescription)")
        }
    }

    func clearProfile(newProfileId profileId: String?) {
        log.debug("Clear profile")
        if let profileId {
            log.debug("set profileId = \(profileId)")
            set(profileId, forKey: Constants.profileIdKey)
        } else {
            removeObject(forKey: Constants.profileIdKey)
        }

        removeObject(forKey: Constants.externalAnalyticsDisabledKey)
        removeObject(forKey: Constants.syncedTransactionsKey)
        removeObject(forKey: Constants.appleSearchAdsSyncDateKey)
        removeObject(forKey: Constants.profileKey)
        clearPaywalls()
        clearBackendProducts()
    }
}
