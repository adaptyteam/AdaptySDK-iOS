//
//  AdaptyProfileParameters.Builder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension AdaptyProfileParameters {
    public final class Builder {
        var parameters: AdaptyProfileParameters

        public convenience init() {
            self.init(AdaptyProfileParameters())
        }

        init(_ values: AdaptyProfileParameters) {
            parameters = values
        }

        public func build() -> AdaptyProfileParameters { parameters }
    }
}

extension AdaptyProfileParameters.Builder {
    @discardableResult
    public func with(firstName value: String?) -> Self {
        parameters.firstName = value
        return self
    }

    @discardableResult
    public func with(lastName value: String?) -> Self {
        parameters.lastName = value
        return self
    }

    @discardableResult
    public func with(gender value: AdaptyProfile.Gender?) -> Self {
        parameters.gender = value
        return self
    }

    @discardableResult
    public func with(birthday value: Date?) -> Self {
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
    public func with(email value: String?) -> Self {
        parameters.email = value
        return self
    }

    @discardableResult
    public func with(phoneNumber value: String?) -> Self {
        parameters.phoneNumber = value
        return self
    }
}

extension AdaptyProfileParameters.Builder {
    func with(customAttributes: AdaptyProfile.CustomAttributes?) -> Self {
        parameters.codableCustomAttributes = customAttributes
        return self
    }

    @discardableResult
    public func withRemoved(customAttributeForKey key: String) throws -> Self {
        try with(customAttribute: .nil, forKey: key)
    }

    @discardableResult
    public func with(customAttribute value: String, forKey key: String) throws -> Self {
        try with(customAttribute: .string(value), forKey: key)
    }

    @discardableResult
    public func with(customAttribute value: Double, forKey key: String) throws -> Self {
        try with(customAttribute: .float(value), forKey: key)
    }

    func with(customAttribute value: AdaptyProfile.CustomAttributeValue, forKey key: String) throws -> Self {
        if let error = AdaptyProfile.CustomAttributes.validateKey(key) { throw error }
        if let error = value.validate() { throw error }
        var attributes = parameters.codableCustomAttributes ?? AdaptyProfile.CustomAttributes()
        attributes.updateValue(value, forKey: key)
        if let error = attributes.validate() { throw error }
        parameters.codableCustomAttributes = attributes
        return self
    }
}

extension AdaptyProfileParameters.Builder {
    @discardableResult
    public func with(analyticsDisabled value: Bool?) -> Self {
        parameters.analyticsDisabled = value
        return self
    }
}

extension AdaptyProfileParameters.Builder {
    @discardableResult
    public func with(facebookAnonymousId value: String?) -> Self {
        parameters.facebookAnonymousId = value
        return self
    }

    @discardableResult
    public func with(amplitudeUserId value: String?) -> Self {
        parameters.amplitudeUserId = value
        return self
    }

    @discardableResult
    public func with(amplitudeDeviceId value: String?) -> Self {
        parameters.amplitudeDeviceId = value
        return self
    }

    @discardableResult
    public func with(mixpanelUserId value: String?) -> Self {
        parameters.mixpanelUserId = value
        return self
    }

    @discardableResult
    public func with(appmetricaProfileId value: String?) -> Self {
        parameters.appmetricaProfileId = value
        return self
    }

    @discardableResult
    public func with(appmetricaDeviceId value: String?) -> Self {
        parameters.appmetricaDeviceId = value
        return self
    }

    @discardableResult
    public func with(oneSignalPlayerId value: String?) -> Self {
        parameters.oneSignalPlayerId = value
        return self
    }

    @discardableResult
    public func with(oneSignalSubscriptionId value: String?) -> Self {
        parameters.oneSignalSubscriptionId = value
        return self
    }

    @discardableResult
    public func with(pushwooshHWID value: String?) -> Self {
        parameters.pushwooshHWID = value
        return self
    }

    @discardableResult
    public func with(firebaseAppInstanceId value: String?) -> Self {
        parameters.firebaseAppInstanceId = value
        return self
    }

    @discardableResult
    public func with(airbridgeDeviceId value: String?) -> Self {
        parameters.airbridgeDeviceId = value
        return self
    }
}

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency

    extension AdaptyProfileParameters.Builder {
        @available(iOS 14, macOS 11.0, visionOS 1.0, *)
        @discardableResult
        public func with(appTrackingTransparencyStatus value: ATTrackingManager.AuthorizationStatus?) -> Self {
            guard let value else {
                parameters.appTrackingTransparencyStatus = nil
                return self
            }
            parameters.appTrackingTransparencyStatus = AdaptyProfileParameters.AppTrackingTransparencyStatus(from: Int(value.rawValue))
            return self
        }
    }
#endif
