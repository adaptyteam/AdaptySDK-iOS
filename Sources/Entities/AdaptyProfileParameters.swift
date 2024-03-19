//
//  AdaptyProfileParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public struct AdaptyProfileParameters {
    public internal(set) var firstName: String?
    public internal(set) var lastName: String?
    public internal(set) var gender: AdaptyProfile.Gender?
    public internal(set) var birthday: String?
    public internal(set) var email: String?
    public internal(set) var phoneNumber: String?
    public internal(set) var facebookAnonymousId: String?
    public internal(set) var amplitudeUserId: String?
    public internal(set) var amplitudeDeviceId: String?
    public internal(set) var mixpanelUserId: String?
    public internal(set) var appmetricaProfileId: String?
    public internal(set) var appmetricaDeviceId: String?
    public internal(set) var oneSignalPlayerId: String?
    public internal(set) var oneSignalSubscriptionId: String?
    public internal(set) var pushwooshHWID: String?
    public internal(set) var firebaseAppInstanceId: String?
    public internal(set) var airbridgeDeviceId: String?

    var storeCountry: String?
    var ipV4Address: String?

    public internal(set) var appTrackingTransparencyStatus: AdaptyProfileParameters.AppTrackingTransparencyStatus?

    var codableCustomAttributes: AdaptyProfile.CustomAttributes?
    public internal(set) var analyticsDisabled: Bool?
    public var customAttributes: [String: Any]? { codableCustomAttributes?.convertToSimpleDictionary() }

    init() {}

    init(storeCountry: String) {
        self.storeCountry = storeCountry
    }

    init(ipV4Address: String) {
        self.ipV4Address = ipV4Address
    }

    init(customAttributes: AdaptyProfile.CustomAttributes) {
        codableCustomAttributes = customAttributes
    }
}

extension AdaptyProfileParameters {
    public static let empty: AdaptyProfileParameters = .init()
    public func builder() -> Builder { Builder(self) }
}

extension AdaptyProfileParameters: Equatable, Sendable {}

extension AdaptyProfileParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case birthday
        case email
        case phoneNumber = "phone_number"
        case facebookAnonymousId = "facebook_anonymous_id"
        case amplitudeUserId = "amplitude_user_id"
        case amplitudeDeviceId = "amplitude_device_id"
        case mixpanelUserId = "mixpanel_user_id"
        case appmetricaProfileId = "appmetrica_profile_id"
        case appmetricaDeviceId = "appmetrica_device_id"
        case storeCountry = "store_country"
        case ipV4Address = "ip_v4_address"

        case appTrackingTransparencyStatus = "att_status"
        case codableCustomAttributes = "custom_attributes"
        case analyticsDisabled = "analytics_disabled"
        case oneSignalPlayerId = "one_signal_player_id"
        case oneSignalSubscriptionId = "one_signal_subscription_id"
        case pushwooshHWID = "pushwoosh_hwid"
        case firebaseAppInstanceId = "firebase_app_instance_id"
        case airbridgeDeviceId = "airbridge_device_id"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(facebookAnonymousId, forKey: .facebookAnonymousId)
        try container.encodeIfPresent(amplitudeUserId, forKey: .amplitudeUserId)
        try container.encodeIfPresent(amplitudeDeviceId, forKey: .amplitudeDeviceId)
        try container.encodeIfPresent(mixpanelUserId, forKey: .mixpanelUserId)
        try container.encodeIfPresent(appmetricaProfileId, forKey: .appmetricaProfileId)
        try container.encodeIfPresent(appmetricaDeviceId, forKey: .appmetricaDeviceId)
        try container.encodeIfPresent(storeCountry, forKey: .storeCountry)
        try container.encodeIfPresent(ipV4Address, forKey: .ipV4Address)
        try container.encodeIfPresent(appTrackingTransparencyStatus, forKey: .appTrackingTransparencyStatus)
        try container.encodeIfPresent(codableCustomAttributes, forKey: .codableCustomAttributes)
        try container.encodeIfPresent(oneSignalPlayerId, forKey: .oneSignalPlayerId)
        try container.encodeIfPresent(oneSignalSubscriptionId, forKey: .oneSignalSubscriptionId)
        try container.encodeIfPresent(pushwooshHWID, forKey: .pushwooshHWID)
        try container.encodeIfPresent(firebaseAppInstanceId, forKey: .firebaseAppInstanceId)
        try container.encodeIfPresent(airbridgeDeviceId, forKey: .airbridgeDeviceId)

        try container.encodeIfPresent(analyticsDisabled, forKey: .analyticsDisabled)
    }
}
