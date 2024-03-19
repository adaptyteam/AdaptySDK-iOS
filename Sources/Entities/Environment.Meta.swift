//
//  Environment.Meta.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension Environment {
    struct Meta: Encodable, Sendable {
        let locale: AdaptyLocale
        let timezone: String
        var includedAnalyticIds: Bool

        init(includedAnalyticIds: Bool) {
            locale = User.locale
            timezone = System.timezone
            self.includedAnalyticIds = includedAnalyticIds
        }

        var storeCountry: String? { Device.storeCountry }
        var ipV4Address: String? { Device.ipV4Address }

        var appTrackingTransparencyStatus: UInt? {
            #if canImport(AppTrackingTransparency)
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *) {
                    return Device.appTrackingTransparencyStatus.rawValue
                }
            #endif
            return nil
        }

        enum CodingKeys: String, CodingKey {
            case appInstallId = "device_id"
            case SDKVersion = "adapty_sdk_version"
            case appBuild = "app_build"
            case appVersion = "app_version"
            case webViewUserAgent = "user_agent"
            case device
            case locale
            case sysVersion = "os"
            case sysName = "platform"
            case timezone
            case idfa
            case idfv
            case screenWidth = "screen_width"
            case screenHeight = "screen_height"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Application.installationIdentifier, forKey: .appInstallId)
            try container.encode(Adapty.SDKVersion, forKey: .SDKVersion)
            try container.encodeIfPresent(Application.build, forKey: .appBuild)
            try container.encodeIfPresent(Application.version, forKey: .appVersion)
            try container.encodeIfPresent(Device.webViewUserAgent, forKey: .webViewUserAgent)
            try container.encode(Device.name, forKey: .device)
            try container.encode(System.version, forKey: .sysVersion)
            try container.encode(System.name, forKey: .sysName)
            try container.encodeIfPresent(locale, forKey: .locale)
            try container.encodeIfPresent(timezone, forKey: .timezone)
            if includedAnalyticIds {
                try container.encodeIfPresent(Device.idfv, forKey: .idfv)
                try container.encodeIfPresent(Device.idfa, forKey: .idfa)
            }
        }
    }
}
