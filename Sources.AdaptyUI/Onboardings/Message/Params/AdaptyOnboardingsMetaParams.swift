//
//  AdaptyOnboardingsMetaParams.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

public struct AdaptyOnboardingsMetaParams: Sendable, Hashable {
    public let onboardingId: String
    public let screenClientId: String
    public let screenIndex: Int
    public let screensTotal: Int

    init(_ body: BodyDecoder.Value) throws {
        let body = try body.asDictionary()
        self.onboardingId = try body["onboarding_id"].asString()
        self.screenClientId = try body["screen_cid"].asString()
        self.screenIndex = try body["screen_index"].asInt()
        self.screensTotal = try body["total_screens"].asInt()
    }
}

extension AdaptyOnboardingsMetaParams: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{onboardingId: \(onboardingId), screenClientId: \(screenClientId), screenIndex: \(screenIndex), screensTotal: \(screensTotal)}"
    }
}
