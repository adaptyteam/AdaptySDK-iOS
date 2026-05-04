//
//  AdaptySubscriptionOfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.08.2025.
//

import Foundation

public enum AdaptySubscriptionOfferType: String, Sendable {
    case introductory
    case promotional
    case winBack = "win_back"
    case code
}

extension AdaptySubscriptionOfferType: Codable {}
