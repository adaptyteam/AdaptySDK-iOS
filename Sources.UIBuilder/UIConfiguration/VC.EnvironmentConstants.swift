//
//  VS.EnvironmentConstants.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//
import Foundation

package extension VC {
    struct EnvironmentConstants: Sendable {
        let sdkVersion: String
        let osName: String
        let osVersion: String
        let deviceModel: String
        let appBundleId: String?
        let appVersion: String?
        let appBuild: String?
        let appCurrentLocale: String?
        let userLocales: [String]
        let userUses24HourClock: Bool
        let flow: FlowConstants

        package init(
            sdkVersion: String,
            osName: String,
            osVersion: String,
            deviceModel: String,
            appBundleId: String?,
            appVersion: String?,
            appBuild: String?,
            appCurrentLocale: String?,
            userLocales: [String],
            userUses24HourClock: Bool,
            flow: FlowConstants
        ) {
            self.sdkVersion = sdkVersion
            self.osName = osName
            self.osVersion = osVersion
            self.deviceModel = deviceModel
            self.appBundleId = appBundleId
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.appCurrentLocale = appCurrentLocale
            self.userLocales = userLocales
            self.userUses24HourClock = userUses24HourClock
            self.flow = flow
        }
    }
}
