//
//  AdaptyInstallationDetails.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.06.2025.
//

import Foundation

public struct AdaptyInstallationDetails: Sendable, Hashable {
    public let id: String?
    public let installTime: Date
    public let appLaunchCount: Int
    public let payload: Payload?
}
