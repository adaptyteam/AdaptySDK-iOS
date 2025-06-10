//
//  Environment.InstallInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

extension Environment {
    struct InstallInfo: Sendable, Encodable {
        let bundleId: String?
        let idfv: String?
        let idfa: String?
        let osName: String
        let osVersion: String
        let deviceModel: String
        let screenWidth: Int?
        let screenHeight: Int?
        let screenScale: Double?
        let timezone: String
        let locale: AdaptyLocale
        let ipV4Address: String?
        let installTime: Date
        
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
            case ipV4Address = "ip_client"
            case installTime = "install_time"
        }
        
        @AdaptyActor
        init?(includedAnalyticIds: Bool) async {
            guard let installTime = Application.installationTime else { return nil }
            await self.init(installTime: installTime, includedAnalyticIds: includedAnalyticIds)
        }
        
        @AdaptyActor
        init(installTime: Date, includedAnalyticIds: Bool) async {
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
            if let scrren = await Device.mainScreenInfo {
                self.screenWidth = scrren.width
                self.screenHeight = scrren.height
                self.screenScale = scrren.scale
            } else {
                self.screenWidth = nil
                self.screenHeight = nil
                self.screenScale = nil
            }
            self.timezone = System.timezone
            self.locale = System.locale
            self.ipV4Address = Device.ipV4Address
            self.installTime = installTime
        }
        
        func encode(to encoder: any Encoder) throws {
            var container: KeyedEncodingContainer<Environment.InstallInfo.CodingKeys> = encoder.container(keyedBy: Environment.InstallInfo.CodingKeys.self)
            try container.encodeIfPresent(self.bundleId, forKey: Environment.InstallInfo.CodingKeys.bundleId)
            try container.encodeIfPresent(self.idfv, forKey: Environment.InstallInfo.CodingKeys.idfv)
            try container.encodeIfPresent(self.idfa, forKey: Environment.InstallInfo.CodingKeys.idfa)
            try container.encode(self.osName, forKey: Environment.InstallInfo.CodingKeys.osName)
            try container.encode(self.osVersion, forKey: Environment.InstallInfo.CodingKeys.osVersion)
            try container.encode("apple", forKey: Environment.InstallInfo.CodingKeys.deviceBrand)
            try container.encode(self.deviceModel, forKey: Environment.InstallInfo.CodingKeys.deviceModel)
            try container.encodeIfPresent(self.screenWidth, forKey: Environment.InstallInfo.CodingKeys.screenWidth)
            try container.encodeIfPresent(self.screenHeight, forKey: Environment.InstallInfo.CodingKeys.screenHeight)
            try container.encodeIfPresent(self.screenScale, forKey: Environment.InstallInfo.CodingKeys.screenScale)
            try container.encode(self.timezone, forKey: Environment.InstallInfo.CodingKeys.timezone)
            try container.encode(Int(Date().timeIntervalSince1970), forKey: Environment.InstallInfo.CodingKeys.time)
            try container.encode(self.locale.normalizedIdentifier, forKey: Environment.InstallInfo.CodingKeys.locale)
            try container.encodeIfPresent(self.ipV4Address, forKey: Environment.InstallInfo.CodingKeys.ipV4Address)
            try container.encode(Int(self.installTime.timeIntervalSince1970), forKey: Environment.InstallInfo.CodingKeys.installTime)
        }
    }
}
