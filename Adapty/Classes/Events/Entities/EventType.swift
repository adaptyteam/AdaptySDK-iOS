//
//  EventType.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

enum EventType {
    case appOpened
    case paywallShowed(PaywallShowedParameters)
    case onboardingScreenShowed(OnboardingScreenParameters)
}

extension EventType: Encodable {
    enum Name {
        static let live = "live"
        static let appOpened = "app_opened"
        static let paywallShowed = "paywall_showed"
        static let onboardingScreenShowed = "onboarding_screen_showed"
    }

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
        }
    }
}
