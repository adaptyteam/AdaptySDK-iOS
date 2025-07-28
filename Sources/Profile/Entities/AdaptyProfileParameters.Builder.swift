//
//  AdaptyProfileParameters.Builder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public extension AdaptyProfileParameters {
    final class Builder {
        var parameters: AdaptyProfileParameters

        public convenience init() {
            self.init(AdaptyProfileParameters())
        }

        init(_ values: AdaptyProfileParameters) {
            self.parameters = values
        }

        public func build() -> AdaptyProfileParameters { parameters }
    }
}

public extension AdaptyProfileParameters.Builder {
    @discardableResult
    func with(firstName value: String?) -> Self {
        parameters.firstName = value.trimmed.nonEmptyOrNil
        return self
    }

    @discardableResult
    func with(lastName value: String?) -> Self {
        parameters.lastName = value.trimmed.nonEmptyOrNil
        return self
    }

    @discardableResult
    func with(gender value: AdaptyProfile.Gender?) -> Self {
        parameters.gender = value
        return self
    }

    @discardableResult
    func with(birthday value: Date?) -> Self {
        guard let value else {
            parameters.birthday = nil
            return self
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        parameters.birthday = formatter.string(from: value)
        return self
    }

    @discardableResult
    func with(email value: String?) -> Self {
        parameters.email = value.trimmed.nonEmptyOrNil
        return self
    }

    @discardableResult
    func with(phoneNumber value: String?) -> Self {
        parameters.phoneNumber = value.trimmed.nonEmptyOrNil
        return self
    }

    @discardableResult
    func with(analyticsDisabled value: Bool?) -> Self {
        parameters.analyticsDisabled = value
        return self
    }

    @discardableResult
    func withRemoved(customAttributeForKey key: String) throws(AdaptyError) -> Self {
        try with(customAttribute: .none, forKey: key)
    }

    @discardableResult
    func with(customAttribute value: String, forKey key: String) throws(AdaptyError) -> Self {
        guard let value = value.trimmed.nonEmptyOrNil else {
            return try with(customAttribute: .none, forKey: key)
        }
        return try with(customAttribute: .string(value), forKey: key)
    }

    @discardableResult
    func with(customAttribute value: Double, forKey key: String) throws(AdaptyError) -> Self {
        try with(customAttribute: .double(value), forKey: key)
    }

    private func with(customAttribute value: AdaptyProfile.CustomAttributeValue, forKey key: String) throws(AdaptyError) -> Self {
        let key = key.trimmed
        try AdaptyProfile.CustomAttributes.validateKey(key)
        try value.validateLenght()
        var attributes = parameters.codableCustomAttributes ?? AdaptyProfile.CustomAttributes()
        attributes.updateValue(value, forKey: key)
        try attributes.validateCount()
        parameters.codableCustomAttributes = attributes
        return self
    }
}

extension AdaptyProfileParameters.Builder: Decodable {
    public convenience init(from decoder: any Decoder) throws {
        var parameters = AdaptyProfileParameters()
        let container = try decoder.container(keyedBy: AdaptyProfileParameters.CodingKeys.self)

        parameters.firstName = try container.decodeIfPresent(String.self, forKey: .firstName).trimmed.nonEmptyOrNil
        parameters.lastName = try container.decodeIfPresent(String.self, forKey: .lastName).trimmed.nonEmptyOrNil
        parameters.gender = try container.decodeIfPresent(AdaptyProfile.Gender.self, forKey: .gender)
        parameters.birthday = try container.decodeIfPresent(String.self, forKey: .birthday).trimmed.nonEmptyOrNil
        parameters.email = try container.decodeIfPresent(String.self, forKey: .email).trimmed.nonEmptyOrNil
        parameters.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber).trimmed.nonEmptyOrNil
        parameters.appTrackingTransparencyStatus = try container.decodeIfPresent(AdaptyProfileParameters.AppTrackingTransparencyStatus.self, forKey: .appTrackingTransparencyStatus)
        parameters.analyticsDisabled = try container.decodeIfPresent(Bool.self, forKey: .analyticsDisabled)

        if let customAttributes = try container.decodeIfPresent(AdaptyProfile.CustomAttributes.self, forKey: .codableCustomAttributes) {
            try customAttributes.validateCount()
            parameters.codableCustomAttributes = customAttributes
        }

        self.init(parameters)
    }
}

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency

public extension AdaptyProfileParameters.Builder {
    @available(iOS 14, macOS 11.0, visionOS 1.0, *)
    @discardableResult
    func with(appTrackingTransparencyStatus value: ATTrackingManager.AuthorizationStatus?) -> Self {
        guard let value else {
            parameters.appTrackingTransparencyStatus = nil
            return self
        }
        parameters.appTrackingTransparencyStatus = AdaptyProfileParameters.AppTrackingTransparencyStatus(from: Int(value.rawValue))
        return self
    }
}
#endif
