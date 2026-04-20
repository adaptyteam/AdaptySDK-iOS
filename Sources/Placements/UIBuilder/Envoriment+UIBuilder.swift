//
//  Envoriment+ UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import AdaptyUIBuilder
import Foundation

extension Environment {
    static func fetchUIBuilderEnvironment() async -> VC.EnvironmentConstants {
        await .init(
            sdkVersion: Adapty.SDKVersion,
            osName: Environment.System.name,
            osVersion: Environment.System.version,
            deviceModel: Environment.Device.model,
            appBundleId: Environment.Application.bundleIdentifier,
            appVersion: Environment.Application.version,
            appBuild: Environment.Application.build,
            appCurrentLocale: Environment.Application.localization,
            userLocales: Environment.System.preferredLanguages,
            userUses24HourClock: Environment.System.uses24HourClock
        )
    }
}

