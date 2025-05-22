//
//  AdaptyProfileParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public struct AdaptyProfileParameters: Sendable, Hashable {
    public internal(set) var firstName: String?
    public internal(set) var lastName: String?
    public internal(set) var gender: AdaptyProfile.Gender?
    public internal(set) var birthday: String?
    public internal(set) var email: String?
    public internal(set) var phoneNumber: String?

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

    init(analyticsDisabled: Bool) {
        self.analyticsDisabled = analyticsDisabled
    }

    init(customAttributes: AdaptyProfile.CustomAttributes) {
        codableCustomAttributes = customAttributes
    }
}

public extension AdaptyProfileParameters {
    static let empty: AdaptyProfileParameters = .init()
    func builder() -> Builder { Builder(self) }
}

extension AdaptyProfileParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case birthday
        case email
        case phoneNumber = "phone_number"

        case storeCountry = "store_country"
        case ipV4Address = "ip_v4_address"

        case appTrackingTransparencyStatus = "att_status"
        case codableCustomAttributes = "custom_attributes"
        case analyticsDisabled = "analytics_disabled"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(storeCountry, forKey: .storeCountry)
        try container.encodeIfPresent(ipV4Address, forKey: .ipV4Address)
        try container.encodeIfPresent(appTrackingTransparencyStatus, forKey: .appTrackingTransparencyStatus)
        try container.encodeIfPresent(codableCustomAttributes, forKey: .codableCustomAttributes)
        try container.encodeIfPresent(analyticsDisabled, forKey: .analyticsDisabled)
    }
}
