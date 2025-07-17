//
//  AdaptyInstallationDetails+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 26.06.2025.
//

import Adapty
import Foundation

extension AdaptyInstallationDetails: Encodable {
    private enum CodingKeys: String, CodingKey {
        case id = "install_id"
        case installTime = "install_time"
        case appLaunchCount = "app_launch_count"
        case payload
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(installTime, forKey: .installTime)
        try container.encode(appLaunchCount, forKey: .appLaunchCount)
        try container.encodeIfPresent(payload?.jsonString, forKey: .payload)
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
