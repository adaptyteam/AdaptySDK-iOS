//
//  AdaptyRefundPreferenceParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.03.2025.
//

import Foundation

struct AdaptyRefundPreferenceParameters: Sendable {
    let refundPreference: AdaptyRefundPreference
}

extension AdaptyRefundPreferenceParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case refundPreference = "custom_preference"
    }
}
