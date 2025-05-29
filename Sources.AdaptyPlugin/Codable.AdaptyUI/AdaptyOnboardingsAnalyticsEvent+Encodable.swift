//
//  AdaptyOnboardingsAnalyticsEvent+Encodable.swift
//  Adapty
//
//  Created by Aleksei Valiano on 29.05.2025.
//

import AdaptyUI
import Foundation

extension AdaptyOnboardingsAnalyticsEvent: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case elementId = "element_id"
        case reply
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .unknown(_, let name):
            try container.encode(name, forKey: .name)
        case .onboardingStarted:
            try container.encode("onboarding_started", forKey: .name)
        case .screenPresented:
            try container.encode("screen_presented", forKey: .name)
        case .screenCompleted(_, let elementId, let reply):
            try container.encode("screen_completed", forKey: .name)
            try container.encodeIfPresent(elementId, forKey: .elementId)
            try container.encodeIfPresent(reply, forKey: .reply)
        case .secondScreenPresented:
            try container.encode("second_screen_presented", forKey: .name)
        case .registrationScreenPresented:
            try container.encode("registration_screen_presented", forKey: .name)
        case .productsScreenPresented:
            try container.encode("products_screen_presented", forKey: .name)
        case .userEmailCollected:
            try container.encode("user_email_collected", forKey: .name)
        case .onboardingCompleted:
            try container.encode("onboarding_completed", forKey: .name)
        }
    }
}
