//
//  ProfileParameterBuilder.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01.10.2020.
//

import Foundation
#if swift(>=5.3)
import AppTrackingTransparency
#endif

@objc public enum Gender: Int {
    case female
    case male
    case other
}

public final class ProfileParameterBuilder: NSObject {

    private var params = Parameters()

    @objc public var email: String? {
        get { params[String.ProfileKey.email] as? String }
        set { params[String.ProfileKey.email] = newValue }
    }

    @objc public var phoneNumber: String? {
        get { params[String.ProfileKey.phoneNumber] as? String }
        set { params[String.ProfileKey.phoneNumber] = newValue }
    }

    @objc public var facebookUserId: String? {
        get { params[String.ProfileKey.facebookUserId] as? String }
        set { params[String.ProfileKey.facebookUserId] = newValue }
    }

    @objc public var facebookAnonymousId: String? {
        get { params[String.ProfileKey.facebookAnonymousId] as? String }
        set { params[String.ProfileKey.facebookAnonymousId] = newValue }
    }

    @objc public var amplitudeUserId: String? {
        get { params[String.ProfileKey.amplitudeUserId] as? String }
        set { params[String.ProfileKey.amplitudeUserId] = newValue }
    }

    @objc public var amplitudeDeviceId: String? {
        get { params[String.ProfileKey.amplitudeDeviceId] as? String }
        set { params[String.ProfileKey.amplitudeDeviceId] = newValue }
    }

    @objc public var mixpanelUserId: String? {
        get { params[String.ProfileKey.mixpanelUserId] as? String }
        set { params[String.ProfileKey.mixpanelUserId] = newValue }
    }

    @objc public var appmetricaProfileId: String? {
        get { params[String.ProfileKey.appmetricaProfileId] as? String }
        set { params[String.ProfileKey.appmetricaProfileId] = newValue }
    }

    @objc public var appmetricaDeviceId: String? {
        get { params[String.ProfileKey.appmetricaDeviceId] as? String }
        set { params[String.ProfileKey.appmetricaDeviceId] = newValue }
    }

    @objc public var firstName: String? {
        get { params[String.ProfileKey.firstName] as? String }
        set { params[String.ProfileKey.firstName] = newValue }
    }

    @objc public var lastName: String? {
        get { params[String.ProfileKey.lastName] as? String }
        set { params[String.ProfileKey.lastName] = newValue }
    }

    @objc public var gender: Gender? {
        get {
            params[String.ProfileKey.gender]
                .flatMap { $0 as? String }
                .flatMap { .init(stringValue: $0) }
        }
        set {
            params[String.ProfileKey.gender] = newValue?.stringValue
        }
    }

    @objc public var birthday: Date? {
        get {
            params[String.ProfileKey.birthday]
                .flatMap { $0 as? String }
                .flatMap { .init(stringValue: $0) }
        }
        set {
            params[String.ProfileKey.birthday] = newValue?.stringValue
        }
    }

    @objc public func setCustomAttributes(_ newValue: Parameters?) {
        params[String.ProfileKey.customAttributes] = newValue?
            .mapValues(makeJSONSerializable(_:))
    }

    #if swift(>=5.3)
    @available(iOS 14, macOS 11.0, *)
    @objc public var atTrackingAuthorizationStatus: ATTrackingManager.AuthorizationStatus? {
        get {
            params[String.ProfileKey.atTrackingAuthorizationStatus]
                .flatMap { $0 as? UInt }
                .flatMap { .init(rawValue: $0) }
        }
        set {
            params[String.ProfileKey.atTrackingAuthorizationStatus] = newValue?.rawValue
        }
    }
    #endif

    func toDictionary() -> Parameters {
        return params
    }

    private func makeJSONSerializable(_ param: Any) -> AnyObject {
        if let null = param as? NSNull {
            return null
        }
        if let string = param as? NSString {
            return string
        }
        if let number = param as? NSNumber,
           !number.doubleValue.isInfinite,
           !number.doubleValue.isNaN {
            return number
        }
        if let date = param as? Date {
            return date.iso8601Value as NSString
        }
        if let array = param as? NSArray {
            return array.map(makeJSONSerializable(_:)) as NSArray
        }
        if let dict = param as? NSDictionary {
            var result = NSMutableDictionary()
            dict.forEach({
                result.setValue(makeJSONSerializable($0.value), forKey: coerceToString(key: $0.key))
            })
            return result
        }
        let description = String(describing: param) as NSString
        LoggerManager.logError(
            "Invalid property value type received of type \(type(of: param)), coercing to \"\(description)\""
        )
        return description
    }

    private func coerceToString(key: Any) -> String {
        if let key = key as? String {
            return key
        } else {
            let description = String(describing: key)
            LoggerManager.logError(
                "Non-string received of type \(type(of: key)), coercing to \"\(description)\""
            )
            return description
        }
    }
}

// MARK: - Deprecations

extension ProfileParameterBuilder {
    @available(*, deprecated, message: "use email instead.")
    @objc public func withEmail(_ email: String) -> Self {
        self.email = email
        return self
    }

    @available(*, deprecated, message: "use phoneNumber instead.")
    @objc public func withPhoneNumber(_ phoneNumber: String) -> Self {
        self.phoneNumber = phoneNumber
        return self
    }

    @available(*, deprecated, message: "use facebookUserId instead.")
    @objc public func withFacebookUserId(_ facebookUserId: String) -> Self {
        self.facebookUserId = facebookUserId
        return self
    }

    @available(*, deprecated, message: "use facebookAnonymousId instead.")
    @objc public func withFacebookAnonymousId(_ facebookAnonymousId: String) -> Self {
        self.facebookAnonymousId = facebookAnonymousId
        return self
    }

    @available(*, deprecated, message: "use amplitudeUserId instead.")
    @objc public func withAmplitudeUserId(_ amplitudeUserId: String) -> Self {
        self.amplitudeUserId = amplitudeUserId
        return self
    }

    @available(*, deprecated, message: "use amplitudeDeviceId instead.")
    @objc public func withAmplitudeDeviceId(_ amplitudeDeviceId: String) -> Self {
        self.amplitudeDeviceId = amplitudeDeviceId
        return self
    }

    @available(*, deprecated, message: "use mixpanelUserId instead.")
    @objc public func withMixpanelUserId(_ mixpanelUserId: String) -> Self {
        self.mixpanelUserId = mixpanelUserId
        return self
    }

    @available(*, deprecated, message: "use appmetricaProfileId instead.")
    @objc public func withAppmetricaProfileId(_ appmetricaProfileId: String) -> Self {
        self.appmetricaProfileId = appmetricaProfileId
        return self
    }

    @available(*, deprecated, message: "use appmetricaDeviceId instead.")
    @objc public func withAppmetricaDeviceId(_ appmetricaDeviceId: String) -> Self {
        self.appmetricaDeviceId = appmetricaDeviceId
        return self
    }

    @available(*, deprecated, message: "use firstName instead.")
    @objc public func withFirstName(_ firstName: String) -> Self {
        self.firstName = firstName
        return self
    }

    @available(*, deprecated, message: "use lastName instead.")
    @objc public func withLastName(_ lastName: String) -> Self {
        self.lastName = lastName
        return self
    }

    @available(*, deprecated, message: "use gender instead.")
    @objc public func withGender(_ gender: Gender) -> Self {
        self.gender = gender
        return self
    }

    @available(*, deprecated, message: "use birthday instead.")
    @objc public func withBirthday(_ birthday: Date) -> Self {
        self.birthday = birthday
        return self
    }

    @available(*, deprecated, message: "use setCustomAttributes instead.")
    @objc public func withCustomAttributes(_ customAttributes: Parameters) -> Self {
        self.setCustomAttributes(customAttributes)
        return self
    }
    
    #if swift(>=5.3)
    @available(iOS 14, macOS 11.0, *)
    @available(*, deprecated, message: "use atTrackingAuthorizationStatus instead.")
    @objc public func withAppTrackingTransparencyStatus(_ appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus) -> Self {
        self.atTrackingAuthorizationStatus = appTrackingTransparencyStatus
        return self
    }
    #endif
}

private extension Gender {
    var stringValue: String {
        switch self {
        case .female: return "f"
        case .male: return "m"
        case .other: return "o"
        }
    }

    init?(stringValue: String) {
        switch stringValue {
        case "f":
            self = .female
        case "m":
            self = .male
        case "o":
            self = .other
        default:
            return nil
        }
    }
}

private extension String {
    enum ProfileKey {
        static let email = "email"
        static let phoneNumber = "phone_number"
        static let facebookUserId = "facebook_user_id"
        static let facebookAnonymousId = "facebook_anonymous_id"
        static let amplitudeUserId = "amplitude_user_id"
        static let amplitudeDeviceId = "amplitude_device_id"
        static let mixpanelUserId = "mixpanel_user_id"
        static let appmetricaProfileId = "appmetrica_profile_id"
        static let appmetricaDeviceId = "appmetrica_device_id"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let gender = "gender"
        static let birthday = "birthday"
        static let customAttributes = "customAttributes"
        static let atTrackingAuthorizationStatus = "att_status"
    }
}
