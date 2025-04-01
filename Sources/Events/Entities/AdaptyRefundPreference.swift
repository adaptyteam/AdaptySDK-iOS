//
//  AdaptyRefundPreference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.03.2025.
//

import Foundation

public enum AdaptyRefundPreference: String, Sendable {
    case noPreference = "no_preference"
    case grant
    case decline
}

extension AdaptyRefundPreference: Codable {}
