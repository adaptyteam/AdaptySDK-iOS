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

public class Adapty {
    
    private static let shared = Adapty()
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
    private lazy var apiManager: ApiManager = {
        return ApiManager()
    }()
    private lazy var kinesisManager: KinesisManager = {
        return KinesisManager()
    }()
    
    private init() { }
    
    public class func activate(_ apiKey: String) {
        Constants.APIKeys.secretKey = apiKey
        shared.configure()
    }
    
    private func configure() {
        AppDelegateSwizzler.startSwizzlingIfPossible(self)
        
        if profile == nil {
            // didn't find existing profile, create a new one
            createProfile()
        } else {
            // sync installation data and receive cognito credentials
            syncInstallation { _, _ in
                self.startTrackingLiveEvent()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.trackLiveEventInBackground()
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
                self.syncInstallation { _, _ in
                    self.startTrackingLiveEvent()
                }
            }
        }
    }
    
    public class func updateProfile(
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
        guard let profileId = shared.profile?.profileId else {
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
        if let idfa = shared.idfa { params["idfa"] = idfa }
        
        shared.apiManager.updateProfile(id: profileId, params: params) { (profile, error) in
            if let profile = profile {
                // do not overwrite in case of error
                shared.profile = profile
            }
            completion?(error)
        }
    }
    
    private func syncInstallation(_ completion: InstallationCompletion? = nil) {
        guard let profileId = profile?.profileId else {
            completion?(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        params["profile_installation_meta_id"] = installation?.profileInstallationMetaId ?? uuid
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
        if let apnsTokenString = apnsTokenString { params["device_token"] = apnsTokenString }
        
        #warning("Handle Adjust params")
        
        apiManager.syncInstallation(params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                self.installation = installation
            }
            completion?(installation, error)
        }
    }
    
    public class func validateReceipt(_ receiptEncoded: String, completion: @escaping JSONCompletion) {
        guard let id = shared.profile?.profileId else {
            completion(nil, NetworkResponse.missingRequiredParams)
            return
        }
        
        shared.apiManager.validateReceipt(params: ["profile_id": id, "receipt_encoded": receiptEncoded], completion: completion)
    }
    
    public class func updateAdjustAttribution(_ attribution: NSObject?, completion: ErrorCompletion? = nil) {
        guard let profileId = shared.profile?.profileId, let installationMetaId = shared.installation?.profileInstallationMetaId else {
            completion?(NetworkResponse.missingRequiredParams)
            return
        }
        
        var params = Parameters()
        
        params["profile_id"] = profileId
        params["profile_installation_meta_id"] = installationMetaId
        if let trackerToken = attribution?.value(forKey: "trackerToken") { params["attribution_tracker_token"] = trackerToken }
        if let trackerName = attribution?.value(forKey: "trackerName") { params["attribution_tracker_name"] = trackerName }
        if let network = attribution?.value(forKey: "network") { params["attribution_network"] = network }
        if let campaign = attribution?.value(forKey: "campaign") { params["attribution_campaign"] = campaign }
        if let adgroup = attribution?.value(forKey: "adgroup") { params["attribution_adgroup"] = adgroup }
        if let creative = attribution?.value(forKey: "creative") { params["attribution_creative"] = creative }
        if let clickLabel = attribution?.value(forKey: "clickLabel") { params["attribution_click_label"] = clickLabel }
        if let adid = attribution?.value(forKey: "adid") { params["attribution_adid"] = adid }
        
        shared.apiManager.syncInstallation(params: params) { (installation, error) in
            if let installation = installation {
                // do not overwrite in case of error
                shared.installation = installation
            }
            completion?(error)
        }
    }
    
    public static var apnsToken: Data? {
        didSet {
            shared.apnsTokenString = apnsToken?.map { String(format: "%02.2hhx", $0) }.joined()
        }
    }
    
    private var apnsTokenString: String? {
        didSet {
            syncInstallation()
        }
    }
    
    public class var customerUserId: String? {
        return shared.profile?.customerUserId
    }
    
    public class func logout() {
        shared.invalidateLiveTrackerTimer()
        shared.profile = nil
        shared.installation = nil
        DefaultsManager.shared.clean()
        
        // automatically create new profile
        shared.createProfile()
    }
    
    //MARK: - Sessions
    
    private var liveTrackerTimer: Timer?
    
    private func startTrackingLiveEvent() {
        guard liveTrackerTimer == nil else {
            return
        }
        
        trackLiveEvent()
        
        liveTrackerTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            self?.trackLiveEvent()
        }
    }
    
    private func invalidateLiveTrackerTimer() {
        liveTrackerTimer?.invalidate()
        liveTrackerTimer = nil
    }
    
    private func trackLiveEvent(completion: ((Error?) -> Void)? = nil) {
        guard let profileId = profile?.profileId, let installation = installation else {
            completion?(NSError(domain: "Adapty Event", code: -1 , userInfo: ["Adapty" : "Can't find valid profileId or profileInstallationMetaId"]))
            return
        }
        
        kinesisManager.trackEvent(.live,
                                  profileID: profileId,
                                  profileInstallationMetaID: installation.profileInstallationMetaId,
                                  secretSigningKey: installation.iamSecretKey,
                                  accessKeyId: installation.iamAccessKeyId,
                                  sessionToken: installation.iamSessionToken,
                                  completion: completion)
    }
    
    private func trackLiveEventInBackground() {
        var eventBackgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        eventBackgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "AdaptyTrackLiveBackgroundTask") {
            // End the task if time expires.
            UIApplication.shared.endBackgroundTask(eventBackgroundTaskID)
            eventBackgroundTaskID = .invalid
        }
        
        assert(eventBackgroundTaskID != .invalid)
        
        DispatchQueue.global().async {
            self.trackLiveEvent() { (error) in
                // End the task assertion.
                UIApplication.shared.endBackgroundTask(eventBackgroundTaskID)
                eventBackgroundTaskID = .invalid
            }
        }
    }
    
}

extension Adapty: AppDelegateSwizzlerDelegate {
    
    func didReceiveAPNSToken(_ deviceToken: Data) {
        Self.apnsToken = deviceToken
    }
    
}

private extension Adapty {
    
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
