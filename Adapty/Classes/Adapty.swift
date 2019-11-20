//
//  Adapty.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation
import AdSupport
import UIKit
import AWSCore

public class Adapty {
    
    public static let shared = Adapty()
    private var profile: ProfileModel? = DefaultsManager.shared.profile {
        didSet {
            DefaultsManager.shared.profile = profile
        }
    }
    private var installation: InstallationModel? = DefaultsManager.shared.installation {
        didSet {
            DefaultsManager.shared.installation = installation
        }
    }
    private var apiManager: ApiManager!
    private var kinesisManager: KinesisManager!
    
    private init() { }
    
    public class func activate(_ apiKey: String) {
        Constants.APIKeys.secretKey = apiKey
        shared.configure()
    }
    
    private func configure() {
        apiManager = ApiManager()
        
        kinesisManager = KinesisManager(identityPoolId: Constants.Kinesis.identityPoolId,
                                        region: Constants.Kinesis.region,
                                        streamName: Constants.Kinesis.streamName)

        if profile == nil {
            // didn't find existing profile, create a new one
            createProfile()
        } else {
            if installation == nil {
                // didn't find existing installation, but found existing user -> create installation on backend
                createInstallation()
            } else {
                // found existing installation -> re-send it updated info to backend
                updateInstallation { _, _ in
                    self.trackSessionStart()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.trackSessionEnd()
        }
    }
    
    private func createProfile(_ completion: ErrorCompletion? = nil) {
        if profile != nil {
            completion?(NetworkResponse.alreadyAuthenticatedError)
            return
        }
        
        var params = Parameters()
        
        if let idfa = idfa { params["idfa"] = idfa }
        params["profile_id"] = uuid
        
        apiManager.createProfile(params: params) { (profile, error, isNew) in
            self.profile = profile
            completion?(error)
            
            if error == nil {
                self.createInstallation()
            }
        }
    }
    
    public func updateProfile(
        customerUserId: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        facebookUserId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        gender: String? = nil,
        birthday: Date? = nil,
        completion: ErrorCompletion? = nil)
    {
        guard let profileId = profile?.profileId else {
            completion?(NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        if let customerUserId = customerUserId { params["customer_user_id"] = customerUserId }
        if let email = email { params["email"] = email }
        if let phoneNumber = phoneNumber { params["phone_number"] = phoneNumber }
        if let facebookUserId = facebookUserId { params["facebook_user_id"] = facebookUserId }
        if let firstName = firstName { params["first_name"] = firstName }
        if let lastName = lastName { params["last_name"] = lastName }
        if let gender = gender { params["gender"] = gender }
        if let birthday = birthday { params["birthday"] = birthday.stringValue }
        if let idfa = idfa { params["idfa"] = idfa }
        
        apiManager.updateProfile(id: profileId, params: params) { (profile, error) in
            if let profile = profile {
                // do not overwrite in case of error
                self.profile = profile
            }
            completion?(error)
        }
    }
    
    private func createInstallation(_ completion: InstallationCompletion? = nil) {
        guard let profileId = profile?.profileId else {
            completion?(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        params["profile_installation_meta_id"] = uuid
        if let sdkVersion = sdkVersion { params["adapty_sdk_version"] = sdkVersion }
        params["adapty_sdk_version_build"] = sdkVersionBuild
        if let appBuild = appBuild { params["app_build"] = appBuild }
        if let appVersion = appVersion { params["app_version"] = appVersion }
        params["device"] = device
        params["locale"] = locale
        params["os"] = OS
        params["platform"] = platform
        params["timezone"] = timezone
        if let deviceIdentifier = deviceIdentifier { params["device_identifier"] = deviceIdentifier }
        
        #warning("Handle Adjust params")
        
        apiManager.createInstallation(params: params) { (installation, error) in
            self.installation = installation
            completion?(installation, error)
            
            self.trackSessionStart()
        }
    }
    
    private func updateInstallation(_ completion: InstallationCompletion? = nil) {
        guard let installationMetaId = installation?.profileInstallationMetaId, let profileId = profile?.profileId else {
            completion?(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        if let sdkVersion = sdkVersion { params["adapty_sdk_version"] = sdkVersion }
        params["adapty_sdk_version_build"] = sdkVersionBuild
        if let appBuild = appBuild { params["app_build"] = appBuild }
        if let appVersion = appVersion { params["app_version"] = appVersion }
        params["device"] = device
        params["locale"] = locale
        params["os"] = OS
        params["platform"] = platform
        params["timezone"] = timezone
        
        #warning("Handle Adjust params")
        
        apiManager.updateInstallation(id: installationMetaId, params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation
            }
            completion?(installation, error)
        }
    }
    
    public func validateReceipt(_ receiptEncoded: String, completion: @escaping JSONCompletion) {
        guard let id = profile?.profileId else {
            completion(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        apiManager.validateReceipt(params: ["profile_id": id, "receipt_encoded": receiptEncoded], completion: completion)
    }
    
    public func updateAdjustAttribution(
        trackerToken: String? = nil,
        trackerName: String? = nil,
        network: String? = nil,
        campaign: String? = nil,
        adgroup: String? = nil,
        creative: String? = nil,
        clickLabel: String? = nil,
        adid: String? = nil,
        completion: ErrorCompletion? = nil)
    {
        guard let installationMetaId = installation?.profileInstallationMetaId, let profileId = profile?.profileId else {
            completion?(NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        if let trackerToken = trackerToken { params["attribution_tracker_token"] = trackerToken }
        if let trackerName = trackerName { params["attribution_tracker_name"] = trackerName }
        if let network = network { params["attribution_network"] = network }
        if let campaign = campaign { params["attribution_campaign"] = campaign }
        if let adgroup = adgroup { params["attribution_adgroup"] = adgroup }
        if let creative = creative { params["attribution_creative"] = creative }
        if let clickLabel = clickLabel { params["attribution_click_label"] = clickLabel }
        if let adid = adid { params["attribution_adid"] = adid }
        
        apiManager.updateInstallation(id: installationMetaId, params: params) { (installation, error) in
            self.installation = installation
            completion?(error)
        }
    }
    
    public var customerUserId: String? {
        return profile?.customerUserId
    }
    
    public func logout() {
        trackSessionEnd()
        profile = nil
        installation = nil
        DefaultsManager.shared.clean()
        
        // automatically create new profile
        createProfile()
    }
    
    //MARK: - Sessions
    
    private func trackSessionStart() {
        if let installationID = self.installation?.profileInstallationMetaId, let profileID = self.profile?.profileId {
            kinesisManager.trackEvent(.sessionStart, profileID: profileID, profileInstallationMetaID: installationID)
        }
    }
    
    private func trackSessionEnd() {
        if let installationID = self.installation?.profileInstallationMetaId, let profileID = self.profile?.profileId {
            kinesisManager.trackEvent(.sessionEnd, profileID: profileID, profileInstallationMetaID: installationID)
        }
    }
    
    //MARK: - Helpers
    
    private var uuid: String {
        return UUID().uuidString
    }
    
    private var idfa: String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    private var sdkVersion: String? {
        return Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    private var sdkVersionBuild: Int {
        return Constants.Versions.SDKBuild
    }
    
    private var appBuild: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    private var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private var device: String {
        return UIDevice.modelName
    }
    
    private var locale: String {
        return Locale.current.identifier
    }
    
    private var OS: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    private var platform: String {
        return UIDevice.current.systemName
    }
    
    private var timezone: String {
        return TimeZone.current.identifier
    }
    
    private var deviceIdentifier: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
}
