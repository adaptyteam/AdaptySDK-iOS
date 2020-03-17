//
//  SessionsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation

class SessionsManager {
    
    private var profileId: String {
        DefaultsManager.shared.profileId
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
        
        liveTrackerTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fireTrackLiveEvent), userInfo: nil, repeats: true)
    }
    
    func invalidateLiveTrackerTimer() {
        liveTrackerTimer?.invalidate()
        liveTrackerTimer = nil
    }
    
    @objc private func fireTrackLiveEvent() {
        trackLiveEvent()
    }
    
    private func trackLiveEvent(completion: ((Error?) -> Void)? = nil) {
        guard let installation = installation else {
            completion?(NSError(domain: "Adapty Event", code: -1 , userInfo: ["Adapty" : "Can't find valid installation"]))
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
    
    #if os(iOS)
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
    #endif
    
}
