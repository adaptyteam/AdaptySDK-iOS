//
//  AdaptyOnboardingsMetaParams+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 27.05.2025.
//

import AdaptyUI
import Foundation

extension AdaptyOnboardingsMetaParams: Encodable {
    private enum CodingKeys: String, CodingKey {
        case onboardingId = "onboarding_id"
        case screenClientId = "screen_cid"
        case screenIndex = "screen_index"
        case screensTotal = "total_screens"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(onboardingId, forKey: .onboardingId)
        try container.encode(screenClientId, forKey: .screenClientId)
        try container.encode(screenIndex, forKey: .screenIndex)
        try container.encode(screensTotal, forKey: .screensTotal)
    }
}
