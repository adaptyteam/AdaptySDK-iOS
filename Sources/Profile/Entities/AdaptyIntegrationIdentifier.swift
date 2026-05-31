//
//  AdaptyIntegrationIdentifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.05.2026.
//

import AdaptyCodable
import Foundation

public struct AdaptyIntegrationIdentifier: Hashable, Sendable {
    public let key: Key
    public let value: String

    public init(key: Key, value: String) {
        self.key = key
        self.value = value.trimmed
    }

    public static func adjustDeviceId(_ value: String) -> Self {
        .init(key: .adjustDeviceId, value: value)
    }

    public static func airbridgeDeviceId(_ value: String) -> Self {
        .init(key: .airbridgeDeviceId, value: value)
    }

    public static func amplitudeUserId(_ value: String) -> Self {
        .init(key: .amplitudeUserId, value: value)
    }

    public static func amplitudeDeviceId(_ value: String) -> Self {
        .init(key: .amplitudeDeviceId, value: value)
    }

    public static func appmetricaDeviceId(_ value: String) -> Self {
        .init(key: .appmetricaDeviceId, value: value)
    }

    public static func appmetricaProfileId(_ value: String) -> Self {
        .init(key: .appmetricaProfileId, value: value)
    }

    public static func appsflyerId(_ value: String) -> Self {
        .init(key: .appsflyerId, value: value)
    }

    public static func branchId(_ value: String) -> Self {
        .init(key: .branchId, value: value)
    }

    public static func facebookAnonymousId(_ value: String) -> Self {
        .init(key: .facebookAnonymousId, value: value)
    }

    public static func firebaseAppInstanceId(_ value: String) -> Self {
        .init(key: .firebaseAppInstanceId, value: value)
    }

    public static func mixpanelUserId(_ value: String) -> Self {
        .init(key: .mixpanelUserId, value: value)
    }

    public static func oneSignalSubscriptionId(_ value: String) -> Self {
        .init(key: .oneSignalSubscriptionId, value: value)
    }

    public static func oneSignalPlayerId(_ value: String) -> Self {
        .init(key: .oneSignalPlayerId, value: value)
    }

    public static func posthogDistinctUserId(_ value: String) -> Self {
        .init(key: .posthogDistinctUserId, value: value)
    }

    public static func pushwooshHWID(_ value: String) -> Self {
        .init(key: .pushwooshHWID, value: value)
    }

    public static func tenjinAnalyticsInstallationId(_ value: String) -> Self {
        .init(key: .tenjinAnalyticsInstallationId, value: value)
    }
}

public extension AdaptyIntegrationIdentifier {
    struct Key: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue.trimmed
        }

        public static let adjustDeviceId = Key(rawValue: "adjust_device_id")
        public static let airbridgeDeviceId = Key(rawValue: "airbridge_device_id")
        public static let amplitudeUserId = Key(rawValue: "amplitude_user_id")
        public static let amplitudeDeviceId = Key(rawValue: "amplitude_device_id")
        public static let appmetricaDeviceId = Key(rawValue: "appmetrica_device_id")
        public static let appmetricaProfileId = Key(rawValue: "appmetrica_profile_id")
        public static let appsflyerId = Key(rawValue: "appsflyer_id")
        public static let branchId = Key(rawValue: "branch_id")
        public static let facebookAnonymousId = Key(rawValue: "facebook_anonymous_id")
        public static let firebaseAppInstanceId = Key(rawValue: "firebase_app_instance_id")
        public static let mixpanelUserId = Key(rawValue: "mixpanel_user_id")
        public static let oneSignalSubscriptionId = Key(rawValue: "one_signal_subscription_id")
        public static let oneSignalPlayerId = Key(rawValue: "one_signal_player_id")
        public static let posthogDistinctUserId = Key(rawValue: "posthog_distinct_user_id")
        public static let pushwooshHWID = Key(rawValue: "pushwoosh_hwid")
        public static let tenjinAnalyticsInstallationId = Key(rawValue: "tenjin_analytics_installation_id")
    }
}

extension AdaptyIntegrationIdentifier.Key: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
}

extension AdaptyIntegrationIdentifier.Key: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}

extension [AdaptyIntegrationIdentifier] {
    var asDictionary: [String: String] {
        [String: String](map { ($0.key.rawValue, $0.value) }, uniquingKeysWith: { _, last in last })
    }

    package static func fromDictionary(_ dictionary: [String: String]) -> Self {
        var result = Self()
        result.reserveCapacity(dictionary.count)
        for (key, value) in dictionary {
            result.append(.init(key: .init(rawValue: key), value: value))
        }
        return result
    }
}

