//
//  ProfileStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class ProfileStorage {
    private enum Constants {
        static let profileKey = "AdaptySDK_Purchaser_Info"
        static let profileIdKey = "AdaptySDK_Profile_Id"
        static let externalAnalyticsDisabledKey = "AdaptySDK_External_Analytics_Disabled"
        static let syncedTransactionsKey = "AdaptySDK_Synced_Bundle_Receipt"
        static let appleSearchAdsSyncDateKey = "AdaptySDK_Apple_Search_Ads_Sync_Date"
        static let crossPlacementStateKey = "AdaptySDK_Cross_Placement_State"
        static let lastOpenedWebPaywallKey = "AdaptySDK_Last_Opened_Web_Paywall"
        static let lastStartAcceleratedSyncProfileKey = "AdaptySDK_Last_Start_Accelerated_Sync_Profile"
    }

    private static let userDefaults = Storage.userDefaults

    static var userId: AdaptyUserId =
        if let profileId = userDefaults.string(forKey: Constants.profileIdKey) {
            AdaptyUserId(
                profileId: profileId,
                customerId: profile?.customerUserId
            )
        } else {
            createAnonymousUserId()
        }

    private static func createAnonymousUserId() -> AdaptyUserId {
        let identifier = UUID().uuidString.lowercased()
        userDefaults.set(identifier, forKey: Constants.profileIdKey)
        log.debug("create anonymous profile (profileId: \(identifier))")
        return AdaptyUserId(
            profileId: identifier,
            customerId: nil
        )
    }

    private static var profile: VH<AdaptyProfile>? = {
        do {
            return try userDefaults.getJSON(VH<AdaptyProfile>.self, forKey: Constants.profileKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    private static var externalAnalyticsDisabled: Bool = userDefaults.bool(forKey: Constants.externalAnalyticsDisabledKey)
    private static var syncedTransactions: Bool = userDefaults.bool(forKey: Constants.syncedTransactionsKey)
    private static var appleSearchAdsSyncDate: Date? = userDefaults.object(forKey: Constants.appleSearchAdsSyncDateKey) as? Date

    private static var lastOpenedWebPaywallDate: Date? = userDefaults.object(forKey: Constants.lastOpenedWebPaywallKey) as? Date

    private static var lastStartAcceleratedSyncProfileDate: Date? = userDefaults.object(forKey: Constants.lastStartAcceleratedSyncProfileKey) as? Date

    private static var crossPlacementState: CrossPlacementState? = {
        do {
            return try userDefaults.getJSON(CrossPlacementState.self, forKey: Constants.crossPlacementStateKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    var userId: AdaptyUserId { Self.userId }

    func getProfile() -> VH<AdaptyProfile>? { Self.profile }

    var externalAnalyticsDisabled: Bool { Self.externalAnalyticsDisabled }

    func setExternalAnalyticsDisabled(_ value: Bool) {
        guard Self.externalAnalyticsDisabled != value else { return }
        Self.externalAnalyticsDisabled = value
        Self.userDefaults.set(value, forKey: Constants.externalAnalyticsDisabledKey)
        log.debug("set externalAnalyticsDisabled = \(value).")
    }

    var syncedTransactions: Bool { Self.syncedTransactions }

    func setSyncedTransactions(_ value: Bool) {
        guard Self.syncedTransactions != value else { return }
        Self.syncedTransactions = value
        Self.userDefaults.set(value, forKey: Constants.syncedTransactionsKey)
        log.debug("set syncedTransactions = \(value).")
    }

    var appleSearchAdsSyncDate: Date? { Self.appleSearchAdsSyncDate }

    func setAppleSearchAdsSyncDate() {
        let now = Date()
        Self.appleSearchAdsSyncDate = now
        Self.userDefaults.set(now, forKey: Constants.appleSearchAdsSyncDateKey)
        log.debug("set appleSearchAdsSyncDate = \(now).")
    }

    var crossPlacementState: CrossPlacementState? { Self.crossPlacementState }

    func setCrossPlacementState(_ value: CrossPlacementState) {
        do {
            try Self.userDefaults.setJSON(value, forKey: Constants.crossPlacementStateKey)
            Self.crossPlacementState = value
            log.debug("saving crossPlacementState success.")
            Log.crossAB.verbose("saving crossPlacementState success = \(value)")
        } catch {
            log.error("saving crossPlacementState fail. \(error.localizedDescription)")
        }
    }

    var lastOpenedWebPaywallDate: Date? { Self.lastOpenedWebPaywallDate }

    func setLastOpenedWebPaywallDate() {
        let now = Date()
        Self.lastOpenedWebPaywallDate = now
        Self.userDefaults.set(now, forKey: Constants.lastOpenedWebPaywallKey)
        log.debug("set lastOpenedWebPaywallDate = \(now).")
    }

    var lastStartAcceleratedSyncProfileDate: Date? { Self.lastStartAcceleratedSyncProfileDate }

    func setLastStartAcceleratedSyncProfileDate() {
        let now = Date()
        Self.lastStartAcceleratedSyncProfileDate = now
        Self.userDefaults.set(now, forKey: Constants.lastStartAcceleratedSyncProfileKey)
        log.debug("set setLastStartAcceleratedSyncProfileDate = \(now).")
    }

    func clearProfile(newProfile: VH<AdaptyProfile>? = nil) {
        Self.clearProfile(newProfile: newProfile)
    }

    func setProfile(_ newProfile: VH<AdaptyProfile>) {
        Self.setProfile(newProfile)
    }

    static func setProfile(_ newProfile: VH<AdaptyProfile>) {
        profile = newProfile
        do {
            try userDefaults.setJSON(newProfile, forKey: Constants.profileKey)
            log.debug("saving profile success.")
        } catch {
            log.error("saving profile fail. \(error.localizedDescription)")
        }
    }

    static func clearProfile(newProfile: VH<AdaptyProfile>? = nil) {
        log.verbose("Clear profile")
        if let newProfile {
            userId = newProfile.userId
            userDefaults.set(userId.profileId, forKey: Constants.profileIdKey)
            log.verbose("set profile \(userId) ")
            setProfile(newProfile)
        } else {
            userId = createAnonymousUserId()
            profile = nil
        }

        userDefaults.removeObject(forKey: Constants.externalAnalyticsDisabledKey)
        externalAnalyticsDisabled = false
        userDefaults.removeObject(forKey: Constants.syncedTransactionsKey)
        syncedTransactions = false
        userDefaults.removeObject(forKey: Constants.appleSearchAdsSyncDateKey)
        appleSearchAdsSyncDate = nil
        userDefaults.removeObject(forKey: Constants.profileKey)
        userDefaults.removeObject(forKey: Constants.crossPlacementStateKey)
        crossPlacementState = nil
        userDefaults.removeObject(forKey: Constants.lastOpenedWebPaywallKey)
        lastOpenedWebPaywallDate = nil
        userDefaults.removeObject(forKey: Constants.lastStartAcceleratedSyncProfileKey)
        lastStartAcceleratedSyncProfileDate = nil

        BackendIntroductoryOfferEligibilityStorage.clear()
        PlacementStorage.clear()
    }
}

extension ProfileStorage {
    func getProfile(with customerUserId: String?) -> VH<AdaptyProfile>? {
        guard let profile = getProfile(),
              profile.isEqualProfileId(userId)
        else { return nil }

        guard let customerUserId else { return profile }
        guard customerUserId == profile.customerUserId else { return nil }
        return profile
    }
}
