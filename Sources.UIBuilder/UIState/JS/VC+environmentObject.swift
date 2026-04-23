//
//  VC+environmentObject.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation
import JavaScriptCore

extension VS {
    enum EnvironmentConstantsKey: String, CaseIterable {
        case platform
        case schemaVersion
        case localizationId
        case localizationDirection
        case sdkVersion
        case osName
        case osVersion
        case deviceVendor
        case deviceModel
        case appBundleId
        case appVersion
        case appBuild
        case appCurrentLocale
        case userLocales
        case userUses24HourClock
    }
}

extension VC {
    func environmentObject(in context: JSContext) -> JSValue? {
        guard let env = JSValue(newObjectIn: context) else { return nil }

        for key in VS.EnvironmentConstantsKey.allCases {
            guard let value = value(for: key) else { continue }
            env.setObject(value.toJSValue(in: context), forKeyedSubscript: key.rawValue as NSString)
        }

        return env
    }

    private func value(for key: VS.EnvironmentConstantsKey) -> (any JSValueConvertable)? {
        switch key {
        case .platform: "ios"
        case .schemaVersion: AdaptyUISchema.formatVersion
        case .localizationId: locale
        case .localizationDirection: isRightToLeft ? "rtl" : "ltr"
        case .sdkVersion: environment.sdkVersion
        case .osName: environment.osName
        case .osVersion: environment.osVersion
        case .deviceVendor: "Apple"
        case .deviceModel: environment.deviceModel
        case .appBundleId: environment.appBundleId
        case .appVersion: environment.appVersion
        case .appBuild: environment.appBuild
        case .appCurrentLocale: environment.appCurrentLocale
        case .userLocales: environment.userLocales
        case .userUses24HourClock: environment.userUses24HourClock
        }
    }
}

