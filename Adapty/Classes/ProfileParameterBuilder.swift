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

public class ProfileParameterBuilder: NSObject {
    
    private var params = Parameters()

    @objc public func withEmail(_ email: String) -> Self {
        params["email"] = email
        return self
    }
    
    @objc public func withPhoneNumber(_ phoneNumber: String) -> Self {
        params["phone_number"] = phoneNumber
        return self
    }
    
    @objc public func withFacebookUserId(_ facebookUserId: String) -> Self {
        params["facebook_user_id"] = facebookUserId
        return self
    }
    
    @objc public func withFacebookAnonymousId(_ facebookAnonymousId: String) -> Self {
        params["facebook_anonymous_id"] = facebookAnonymousId
        return self
    }
    
    @objc public func withAmplitudeUserId(_ amplitudeUserId: String) -> Self {
        params["amplitude_user_id"] = amplitudeUserId
        return self
    }
    
    @objc public func withAmplitudeDeviceId(_ amplitudeDeviceId: String) -> Self {
        params["amplitude_device_id"] = amplitudeDeviceId
        return self
    }
    
    @objc public func withMixpanelUserId(_ mixpanelUserId: String) -> Self {
        params["mixpanel_user_id"] = mixpanelUserId
        return self
    }
    
    @objc public func withAppmetricaProfileId(_ appmetricaProfileId: String) -> Self {
        params["appmetrica_profile_id"] = appmetricaProfileId
        return self
    }
    
    @objc public func withAppmetricaDeviceId(_ appmetricaDeviceId: String) -> Self {
        params["appmetrica_device_id"] = appmetricaDeviceId
        return self
    }
    
    @objc public func withFirstName(_ firstName: String) -> Self {
        params["first_name"] = firstName
        return self
    }
    
    @objc public func withLastName(_ lastName: String) -> Self {
        params["last_name"] = lastName
        return self
    }
    
    @objc public func withGender(_ gender: Gender) -> Self {
        switch gender {
        case .female: params["gender"] = "f"
        case .male: params["gender"] = "m"
        case .other: params["gender"] = "o"
        }
        return self
    }
    
    @objc public func withBirthday(_ birthday: Date) -> Self {
        params["birthday"] = birthday.stringValue
        return self
    }
    
    @objc public func withCustomAttributes(_ customAttributes: Parameters) -> Self {
        params["custom_attributes"] = customAttributes
        return self
    }
    
    #if swift(>=5.3)
    @available(iOS 14, macOS 11.0, *)
    @objc public func withAppTrackingTransparencyStatus(_ appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus) -> Self {
        params["att_status"] = appTrackingTransparencyStatus.rawValue
        return self
    }
    #endif
    
    func toDictionary() -> Parameters {
        return params
    }
    
}
