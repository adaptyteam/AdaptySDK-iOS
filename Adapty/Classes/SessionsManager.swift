//
//  SessionsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import UIKit

class SessionsManager {
    
    private var liveTrackerTimer: Timer?
    private lazy var kinesisManager: KinesisManager = {
        return KinesisManager.shared
    }()
    
    private var purchaserInfoTimer: Timer?
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.trackLiveEventInBackground()
        }
    }
    
    deinit {
        invalidateTimers()
    }
    
    func invalidateTimers() {
        invalidateLiveTrackerTimer()
        invalidatePurchaserInfoTimer()
    }
    
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
    
    private func trackLiveEvent(completion: ErrorCompletion? = nil) {
        kinesisManager.trackEvent(.live, completion: completion)
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
            self.trackLiveEvent() { (_) in
                // End the task assertion.
                UIApplication.shared.endBackgroundTask(eventBackgroundTaskID)
                eventBackgroundTaskID = .invalid
            }
        }
    }
    
    func startUpdatingPurchaserInfo() {
        guard purchaserInfoTimer == nil else {
            return
        }
        
        purchaserInfoTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fireUpdatePurchaserInfo), userInfo: nil, repeats: true)
    }
    
    func invalidatePurchaserInfoTimer() {
        purchaserInfoTimer?.invalidate()
        purchaserInfoTimer = nil
    }
    
    @objc private func fireUpdatePurchaserInfo() {
        Adapty.getPurchaserInfo { (_, _) in }
    }
    
}
