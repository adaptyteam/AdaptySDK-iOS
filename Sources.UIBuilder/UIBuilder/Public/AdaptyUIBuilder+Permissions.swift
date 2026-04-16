//
//  AdaptyUIPermission.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Goncharov on 26.03.2026.
//

import Foundation

public enum AdaptyUIPermission: Sendable, Hashable {
    /// A custom or unrecognized permission type. The associated value contains
    /// the raw permission string from the paywall configuration.
    /// Android-only permissions (e.g., `"phone"`, `"sms"`) map to this case on iOS.
    case custom(String)
    /// Push notification permission (`UNUserNotificationCenter`).
    case push
    /// Camera access permission (`AVCaptureDevice`).
    case camera
    /// Microphone access permission (`AVCaptureDevice`).
    case microphone
    /// Location "when in use" permission (`CLLocationManager`).
    case locationWhenInUse
    /// Location "always" permission (`CLLocationManager`).
    case locationAlways
    /// Location full accuracy permission (`CLLocationManager`).
    case locationFullAccuracy
    /// Photo library access permission (`PHPhotoLibrary`).
    case photos
    /// Contacts access permission (`CNContactStore`).
    case contacts
    /// App Tracking Transparency permission (`ATTrackingManager`).
    case tracking
    /// Calendar access permission (`EKEventStore`).
    case calendar
    /// Bluetooth access permission (`CBCentralManager`).
    case bluetooth
    /// Motion and fitness data permission (`CMMotionActivityManager`).
    case motion
    /// Reminders access permission (`EKEventStore`).
    case reminders
    /// Speech recognition permission (`SFSpeechRecognizer`).
    case speech
    /// Media library access permission (`MPMediaLibrary`).
    case mediaLibrary
    /// Local network access permission.
    case localNetwork
    /// Focus status access permission (`INFocusStatusCenter`).
    case focusStatus
    /// HomeKit access permission (`HMHomeManager`).
    case homekit
    /// HealthKit access permission (`HKHealthStore`).
    case health
    /// Siri authorization permission (`INPreferences`).
    case siri
    /// Apple Music / MusicKit access permission (`SKCloudServiceController`).
    case music
}

extension AdaptyUIPermission {
    package init(jsString: String) {
        switch jsString {
        case "push": self = .push
        case "camera": self = .camera
        case "microphone": self = .microphone
        case "location_when_use": self = .locationWhenInUse
        case "location_always": self = .locationAlways
        case "location_full_accuracy": self = .locationFullAccuracy
        case "photos": self = .photos
        case "contacts": self = .contacts
        case "tracking": self = .tracking
        case "calendar": self = .calendar
        case "bluetooth": self = .bluetooth
        case "motion": self = .motion
        case "reminders": self = .reminders
        case "speech": self = .speech
        case "media_library": self = .mediaLibrary
        case "local_network": self = .localNetwork
        case "focus_status": self = .focusStatus
        case "homekit": self = .homekit
        case "health": self = .health
        case "siri": self = .siri
        case "music": self = .music
        default: self = .custom(jsString)
        }
    }
}

public enum AdaptyUIPermissionResult: Sendable {
    case granted(String?)
    case denied(String?)
}

extension AdaptyUIPermissionResult {
    package var isGranted: Bool {
        switch self {
        case .granted: true
        case .denied: false
        }
    }

    package var detail: String? {
        switch self {
        case let .granted(detail), let .denied(detail):
            detail
        }
    }
}
