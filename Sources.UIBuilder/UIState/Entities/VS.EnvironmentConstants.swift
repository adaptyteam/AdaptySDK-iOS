//
//  VS.EnvironmentConstants.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//
import Foundation

extension VS {
    protocol EnvironmentConstants {
        var osName: String { get }
        var osVersion: String { get }
        var sdkVersion: String { get }
        var deviceModel: String { get }
        var appBundleId: String { get }
        var appVersion: String { get }
        var appBuild: String { get }
        var appCurrentLocale: String { get }
        var userLocales: [String] { get }
        var userTimeFormatIs24: Bool { get }
    }
}

private enum EnvironmentConstantsKey: String {
    case platform = "SDK_PLATFORM"
    case schemaVersion = "SDK_SCHEMA_VERSION"
    case localizationId = "LOCALIZATION_ID"
    case localizationDirection = "LOCALIZATION_DIRECTION"
    case sdkVersion = "SDK_VERSION"
    case osName = "OS_NAME"
    case osVersion = "OS_VERSION"
    case deviceVendor = "DEVICE_VENDOR"
    case deviceModel = "DEVICE_MODEL"
    case appBundleId = "APP_BUNDLE_ID"
    case appVersion = "APP_VERSION"
    case appBuild = "APP_BUILD"
    case appCurrentLocale = "APP_CURRENT_LOCALE"
    case userLocales = "DEVICE_LOCALES"
    case userTimeFormatIs24 = "DEVICE_TIMEFORMAT_IS24"
}

extension VS.EnvironmentConstants {
    private typealias Key = EnvironmentConstantsKey

    func export(_ config: AdaptyUIConfiguration) -> [String: any JSValueConvertable] {
        [
            Key.platform.rawValue: "ios",
            Key.schemaVersion.rawValue: AdaptyUISchema.formatVersion,
            Key.localizationId.rawValue: config.locale,
            Key.localizationDirection.rawValue: config.isRightToLeft ? "rtl" : "ltr",
            Key.osName.rawValue: osName,
            Key.osVersion.rawValue: osVersion,
            Key.sdkVersion.rawValue: sdkVersion,
            Key.deviceVendor.rawValue: "Apple",
            Key.deviceModel.rawValue: deviceModel,
            Key.appBundleId.rawValue: appBundleId,
            Key.appVersion.rawValue: appVersion,
            Key.appBuild.rawValue: appBuild,
            Key.appCurrentLocale.rawValue: appCurrentLocale,
            Key.userLocales.rawValue: userLocales,
            Key.userTimeFormatIs24.rawValue: userTimeFormatIs24,
        ]
    }
}

