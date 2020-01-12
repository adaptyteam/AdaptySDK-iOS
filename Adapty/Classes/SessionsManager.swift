//
//  SessionsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

class SessionsManager {
    
    private var profile: ProfileModel? {
        DefaultsManager.shared.profile
    }
    private var installation: InstallationModel? {
        DefaultsManager.shared.installation
    }
    private var liveTrackerTimer: Timer?
    private lazy var kinesisManager: KinesisManager = {
        return KinesisManager()
    }()
    
    func startTrackingLiveEvent() {
        guard liveTrackerTimer == nil else {
            return
        }
        
        trackLiveEvent()
        
        liveTrackerTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            self?.trackLiveEvent()
        }
    }
    
    func invalidateLiveTrackerTimer() {
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
    
    func trackLiveEventInBackground() {
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
