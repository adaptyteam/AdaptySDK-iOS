//
//  Environment.InstallInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

extension Environment {
    struct InstallInfo: Sendable, Hashable, Encodable {
        let bundleId: String?
        let idfv: String?
        let idfa: String?
        let osName: String
        let osVersion: String
        let deviceModel: String
        let screen: Device.ScreenInfo?
        let timezone: String
        let locale: AdaptyLocale
        let installTime: Date
        let appLaunchCount: Int

        enum CodingKeys: String, CodingKey {
            case bundleId = "bundle_id"
            case idfv
            case idfa
            case osName = "os"
            case osVersion = "os_major"
            case deviceBrand = "device_brand"
            case deviceModel = "device_model"
            case screenWidth = "screen_w"
            case screenHeight = "screen_h"
            case screenScale = "screen_dpr"
            case timezone
            case time = "client_time"
            case locale
            case installTime = "install_time"
        }

        @AdaptyActor
        init(
            installTime: Date,
            appLaunchCount: Int,
            includedAnalyticIds: Bool
        ) async {
            self.bundleId = Application.bundleIdentifier
            if includedAnalyticIds {
                self.idfv = await Device.idfv
                self.idfa = await Device.idfa
            } else {
                self.idfv = nil
                self.idfa = nil
            }
            self.osName = await System.name
            self.osVersion = await System.version
            self.deviceModel = Device.model
            self.screen = await Device.mainScreenInfo
            self.timezone = System.timezone
            self.locale = System.locale
            self.installTime = installTime
            self.appLaunchCount = appLaunchCount
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(bundleId, forKey: .bundleId)
            try container.encodeIfPresent(idfv, forKey: .idfv)
            try container.encodeIfPresent(idfa, forKey: .idfa)
            try container.encode(osName, forKey: .osName)
            try container.encode(osVersion, forKey: .osVersion)
            try container.encode("apple", forKey: .deviceBrand)
            try container.encode(deviceModel, forKey: .deviceModel)
            if let screen = screen {
                try container.encode(screen.width, forKey: .screenWidth)
                try container.encode(screen.height, forKey: .screenHeight)
                try container.encode(screen.scale, forKey: .screenScale)
            }
            try container.encode(timezone, forKey: .timezone)
            try container.encode(Int(Date().timeIntervalSince1970), forKey: .time)
            try container.encode(locale.normalizedIdentifier, forKey: .locale)
            try container.encode(Int(installTime.timeIntervalSince1970), forKey: .installTime)
        }
    }
}
