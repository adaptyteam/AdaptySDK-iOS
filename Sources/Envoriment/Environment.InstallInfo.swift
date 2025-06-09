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
        let deviceBrand: String
        let deviceModel: String
        let screenWidth: Int?
        let screenHeight: Int?
        let screenScale: Double?
        let timezone: String
        let locale: String
        let ipV4Address: String?
        let time: Int
        let installTime: Int
        
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
            guard let installAt = Application.installationTime else { return nil }
            
            bundleId = Application.bundleIdentifier
            if includedAnalyticIds {
                idfv = await Device.idfv
                idfa = await Device.idfa
            } else {
                idfv = nil
                idfa = nil
            }
            osName = await System.name
            osVersion = await System.version
            deviceBrand = "apple"
            deviceModel = Device.model
            if let scrren = await Device.mainScreenInfo {
                screenWidth = scrren.width
                screenHeight = scrren.height
                screenScale = scrren.scale
            } else {
                screenWidth = nil
                screenHeight = nil
                screenScale = nil
            }
            
            timezone = System.timezone
            locale = System.locale.normalizedIdentifier
            ipV4Address = Device.ipV4Address
            
            installTime = Int(installAt.timeIntervalSince1970)
            time = Int(Date().timeIntervalSince1970)
        }
    }
}
