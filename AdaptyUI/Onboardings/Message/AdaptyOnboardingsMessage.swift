//
//  OnboardingsMessage.swift
//
//
//  Created by Aleksei Valiano on 30.07.2024
//
//

import Foundation

enum AdaptyOnboardingsMessage: Sendable, Hashable {
    case analytics(AdaptyOnboardingsAnalyticsEvent)
    case stateUpdated(AdaptyOnboardingsStateUpdatedAction)
    case openPaywall(AdaptyOnboardingsOpenPaywallAction)
    case custom(AdaptyOnboardingsCustomAction)
    case close(AdaptyOnboardingsCloseAction)
    case didFinishLoading(OnboardingsDidFinishLoadingAction)
}

extension AdaptyOnboardingsMessage: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .analytics(event):
            "{\(TypeName.analytics.rawValue) event: \(event.debugDescription)}"
        case let .stateUpdated(action):
            "{\(TypeName.stateUpdated.rawValue) action: \(action.debugDescription)}"
        case let .openPaywall(action):
            "{\(TypeName.openPaywall.rawValue) action: \(action.debugDescription)}"
        case let .custom(action):
            "{\(TypeName.custom.rawValue) action: \(action.debugDescription)}"
        case let .close(action):
            "{\(TypeName.close.rawValue) action: \(action.debugDescription)}"
        case let .didFinishLoading(action):
            "{\(TypeName.didFinishLoading.rawValue) action: \(action.debugDescription)}"
        }
    }
}
