//
//  AdaptyAttributionSource.swift
//  AdaptySDK
//
//  Created by Ilya Laryionau on 26.12.24.
//

extension AdaptyIntegrationIdentifier {
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

    public static func appMetricaDeviceId(_ value: String) -> Self {
        .init(key: .appMetricaDeviceId, value: value)
    }

    public static func appMetricaProfileId(_ value: String) -> Self {
        .init(key: .appMetricaProfileId, value: value)
    }

    public static func appsFlyerId(_ value: String) -> Self {
        .init(key: .appsFlyerId, value: value)
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

    public static func oneSignalPlayerId(_ value: String) -> Self {
        .init(key: .oneSignalPlayerId, value: value)
    }

    public static func pushwooshHWID(_ value: String) -> Self {
        .init(key: .pushwooshHWID, value: value)
    }
}

extension AdaptyIntegrationIdentifier.Key {
    public static var adjustDeviceId: Self { "adjust_device_id" }
    public static var airbridgeDeviceId: Self { "airbridge_device_id" }
    public static var amplitudeUserId: Self { "amplitude_user_id" }
    public static var amplitudeDeviceId: Self { "amplitude_device_id" }
    public static var appMetricaDeviceId: Self { "appmetrica_device_id" }
    public static var appMetricaProfileId: Self { "appmetrica_profile_id" }
    public static var appsFlyerId: Self { "appsflyer_id" }
    public static var facebookAnonymousId: Self { "facebook_anonymous_id" }
    public static var firebaseAppInstanceId: Self { "firebase_app_instance_id" }
    public static var mixpanelUserId: Self { "mixpanel_user_id" }
    public static var oneSignalPlayerId: Self { "one_signal_player_id" }
    public static var pushwooshHWID: Self { "pushwoosh_hwid" }
}

public struct AdaptyIntegrationIdentifier {
    public struct Key: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public let key: Key
    public let value: String

    public init(key: Key, value: String) {
        self.key = key
        self.value = value
    }
}

extension AdaptyIntegrationIdentifier: Equatable {}
extension AdaptyIntegrationIdentifier: Hashable {}
extension AdaptyIntegrationIdentifier: Sendable {}

extension AdaptyIntegrationIdentifier.Key: CustomStringConvertible {
    public var description: String {
        return String(describing: self.rawValue)
    }
}

extension AdaptyIntegrationIdentifier.Key: Equatable {}

extension AdaptyIntegrationIdentifier.Key: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}

extension AdaptyIntegrationIdentifier.Key: Hashable {}

extension AdaptyIntegrationIdentifier.Key: Sendable {}
