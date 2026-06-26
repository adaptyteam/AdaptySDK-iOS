//
//  AdaptyUIPermission+WireValue.swift
//  AdaptyPlugin
//

import AdaptyUIBuilder

extension AdaptyUIPermission {
    /// The cross-platform string for this permission — the exact inverse of
    /// `AdaptyUIPermission.init(jsString:)`, so the value round-trips back to the flow.
    var wireValue: String {
        switch self {
        case let .custom(value): value
        case .push: "push"
        case .camera: "camera"
        case .microphone: "microphone"
        case .locationWhenInUse: "location_when_use"
        case .locationAlways: "location_always"
        case .locationFullAccuracy: "location_full_accuracy"
        case .photos: "photos"
        case .contacts: "contacts"
        case .tracking: "tracking"
        case .calendar: "calendar"
        case .bluetooth: "bluetooth"
        case .motion: "motion"
        case .reminders: "reminders"
        case .speech: "speech"
        case .mediaLibrary: "media_library"
        case .localNetwork: "local_network"
        case .focusStatus: "focus_status"
        case .homekit: "homekit"
        case .health: "health"
        case .siri: "siri"
        case .music: "music"
        }
    }
}
