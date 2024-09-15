//
//  Event.swift
//  Adapty
//
//  Created by Aleksei Valiano on 14.09.2024
//
//

import Foundation

enum Event: Sendable {
    case appOpened
    case paywallShowed(AdaptyPaywallShowedParameters)
    case paywallVariationAssigned(AdaptyPaywallVariationAssignedParameters)
    case onboardingScreenShowed(AdaptyOnboardingScreenParameters)
    case system(any AdaptySystemEventParameters)
}

extension Event {
    var isLowPriority: Bool {
        switch self {
        case .system: true
        default: false
        }
    }
}

extension Event: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Event.CodingKeys.self)
        switch self {
        case .appOpened:
            break
        case let .paywallShowed(value):
            try value.encode(to: encoder)
        case let .onboardingScreenShowed(value):
            try value.encode(to: encoder)
        case let .paywallVariationAssigned(value):
            try value.encode(to: encoder)
        case let .system(value):
            let data = try Event.encoder.encode(value)
            let string = String(decoding: data, as: UTF8.self)
            try container.encode(string, forKey: .customData)
        }
    }
}
