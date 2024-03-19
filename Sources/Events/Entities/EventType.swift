//
//  EventType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

enum EventType {
    case appOpened
    case paywallShowed(AdaptyPaywallShowedParameters)
    case onboardingScreenShowed(AdaptyOnboardingScreenParameters)
    case system(AdaptySystemEventParameters)
}

extension EventType {
    enum Name {
        static let appOpened = "app_opened"
        static let paywallShowed = "paywall_showed"
        static let onboardingScreenShowed = "onboarding_screen_showed"
        static let system = "system_log"
    }

    static let systemEvents = [Name.system]

    var name: String {
        switch self {
        case .appOpened:
            Name.appOpened
        case .paywallShowed:
            Name.paywallShowed
        case .onboardingScreenShowed:
            Name.onboardingScreenShowed
        case .system:
            Name.system
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
        case let .system(value):
            try container.encode(Name.system, forKey: .type)
            let data = try Backend.encoder.encode(value)
            let string = String(decoding: data, as: UTF8.self)
            try container.encode(string, forKey: .customData)
        }
    }
}
