//
//  EventType.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

enum EventType {
    case appOpened
    case paywallShowed(AdaptyPaywallShowedParameters)
    case onboardingScreenShowed(AdaptyOnboardingScreenParameters)
    case systemLog
}

extension EventType {
    enum Name {
        static let appOpened = "app_opened"
        static let paywallShowed = "paywall_showed"
        static let onboardingScreenShowed = "onboarding_screen_showed"
        static let systemLog = "system_log"
    }

    var name: String {
        switch self {
        case .appOpened:
            return Name.appOpened
        case .paywallShowed:
            return Name.paywallShowed
        case .onboardingScreenShowed:
            return Name.onboardingScreenShowed
        case .systemLog:
            return Name.systemLog
        }
    }
}

extension EventType: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Event.CodingKeys.self)
        switch self {
        case .appOpened:
            try container.encode(Name.appOpened, forKey: .type)
        case let .paywallShowed(value):
            try container.encode(Name.paywallShowed, forKey: .type)
            try value.encode(to: encoder)
        case let .onboardingScreenShowed(value):
            try container.encode(Name.onboardingScreenShowed, forKey: .type)
            try value.encode(to: encoder)
        case .systemLog:
            try container.encode(Name.systemLog, forKey: .type)
        }
    }
}
