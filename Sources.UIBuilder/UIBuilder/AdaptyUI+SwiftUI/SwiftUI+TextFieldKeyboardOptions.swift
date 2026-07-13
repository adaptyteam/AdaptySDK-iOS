//
//  SwiftUI+TextFieldKeyboardOptions.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 13/03/2026.
//

#if canImport(UIKit)

import SwiftUI
// UIKeyboardType and UITextContentType are UIKit types not re-exported by SwiftUI
import UIKit

extension VC.TextField.KeyboardOptions {
    var uiKeyboardType: UIKeyboardType? {
        switch keyboardType {
        case "default": return .default
        case "email": return .emailAddress
        case "number": return .numberPad
        case "decimal": return .decimalPad
        case "phone": return .phonePad
        case "url": return .URL
        case "ascii": return .asciiCapable
        default: return nil
        }
    }

    var uiTextContentType: UITextContentType? {
        // iOS 13+
        switch contentType {
        case "email": return .emailAddress
        case "phone": return .telephoneNumber
        case "username": return .username
        case "password": return .password
        case "new_password": return .newPassword
        case "name": return .name
        case "given_name": return .givenName
        case "family_name": return .familyName
        case "middle_name": return .middleName
        case "name_prefix": return .namePrefix
        case "name_suffix": return .nameSuffix
        case "one_time_code": return .oneTimeCode
        case "postal_code": return .postalCode
        case "street_address": return .streetAddressLine1
        case "city": return .addressCity
        case "state": return .addressState
        case "country": return .countryName
        case "credit_card_number": return .creditCardNumber
        default: break
        }

        // iOS 17+
        if #available(iOS 17.0, *) {
            switch contentType {
            case "credit_card_security_code": return .creditCardSecurityCode
            case "credit_card_expiration": return .creditCardExpiration
            case "credit_card_expiration_month": return .creditCardExpirationMonth
            case "credit_card_expiration_year": return .creditCardExpirationYear
            case "birthdate_day": return .birthdateDay
            case "birthdate_month": return .birthdateMonth
            case "birthdate_year": return .birthdateYear
            case "birthdate": return .birthdate
            case "flight_number": return .flightNumber
            default: break
            }
        }

        return nil
    }
}

extension View {
    @ViewBuilder
    func applyKeyboardOptions(_ options: VC.TextField.KeyboardOptions?) -> some View {
        if let options {
            applyKeyboardType(options.uiKeyboardType)
                .applyTextContentType(options.uiTextContentType)
                .applyAutocapitalization(options.autocapitalizationType)
                .applySubmitLabel(options.submitButton)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyKeyboardType(_ type: UIKeyboardType?) -> some View {
        if let type {
            keyboardType(type)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyTextContentType(_ type: UITextContentType?) -> some View {
        if let type {
            textContentType(type)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyAutocapitalization(_ value: String?) -> some View {
        if #available(iOS 15.0, *) {
            let mapped: TextInputAutocapitalization? = {
                switch value {
                case "never": return .never
                case "sentences": return .sentences
                case "words": return .words
                case "characters": return .characters
                default: return nil
                }
            }()
            if let mapped {
                textInputAutocapitalization(mapped)
            } else {
                self
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func applySubmitLabel(_ value: String?) -> some View {
        if #available(iOS 15.0, *) {
            let mapped: SubmitLabel? = {
                switch value {
                case "done": return .done
                case "go": return .go
                case "search": return .search
                case "send": return .send
                case "next": return .next
                case "return": return .return
                default: return nil
                }
            }()
            if let mapped {
                submitLabel(mapped)
            } else {
                self
            }
        } else {
            self
        }
    }
}

#endif
