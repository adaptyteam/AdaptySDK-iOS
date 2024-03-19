//
//  ProfileStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

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
        Log.debug("UserDefaults: profileId = \(identifier)")
        set(identifier, forKey: Constants.profileIdKey)
        return identifier
    }

    var externalAnalyticsDisabled: Bool {
        bool(forKey: Constants.externalAnalyticsDisabledKey)
    }

    func setExternalAnalyticsDisabled(_ value: Bool) {
        Log.debug("UserDefaults: setExternalAnalyticsDisabled = \(value).")
        set(value, forKey: Constants.externalAnalyticsDisabledKey)
    }

    func getProfile() -> VH<AdaptyProfile>? {
        guard let data = data(forKey: Constants.profileKey) else { return nil }
        do {
            return try Backend.decoder.decode(VH<AdaptyProfile>.self, from: data)
        } catch {
            Log.warn(error.localizedDescription)
            return nil
        }
    }

    var syncedTransactions: Bool {
        bool(forKey: Constants.syncedTransactionsKey)
    }

    func setSyncedTransactions(_ value: Bool) {
        Log.debug("UserDefaults: syncedBundleReceipt = \(value).")
        set(value, forKey: Constants.syncedTransactionsKey)
    }

    var appleSearchAdsSyncDate: Date? {
        object(forKey: Constants.appleSearchAdsSyncDateKey) as? Date
    }

    func setAppleSearchAdsSyncDate() {
        let date = Date()
        Log.debug("UserDefaults: appleSearchAdsSyncDate = \(date).")
        set(date, forKey: Constants.appleSearchAdsSyncDateKey)
    }

    func setProfile(_ profile: VH<AdaptyProfile>) {
        do {
            let data = try Backend.encoder.encode(profile)
            Log.debug("UserDefaults: saving profile success.")
            set(data, forKey: Constants.profileKey)
        } catch {
            Log.error("UserDefaults: saving profile fail. \(error.localizedDescription)")
        }
    }

    func clearProfile(newProfileId profileId: String?) {
        Log.debug("UserDefaults: Clear profile")
        if let profileId {
            Log.debug("UserDefaults: profileId = \(profileId)")
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
