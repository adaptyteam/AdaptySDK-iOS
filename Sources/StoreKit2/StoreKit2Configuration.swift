//
//  StoreKit2Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 9.05.2023
//

/// Defines StoreKit 2 utilization behaviour.
public enum StoreKit2Usage {
    public static let `default`: Self = .forIntroEligibilityCheck

    /// Adapty will never use StoreKit 2.
    case disabled

    /// Adapty will use StoreKit 2 functionality to optimize some features.
    ///
    /// For now it can be used only to determine introductory offers eligibility.
    ///
    /// Note, that StoreKit 2 is only available with iOS 15.0 and newer.
    case forIntroEligibilityCheck
}

extension Adapty.Configuration {
    static var useStoreKit2Configuration: String {
        guard Environment.StoreKit2.available else { return "unavailable" }
        switch _storeKit2Usage {
        case .disabled: return "disabled"
        case .forIntroEligibilityCheck: return "enabled_for_introductory_offer_eligibility"
        }
    }

    static var enabledStoreKit2IntroEligibilityCheck: Bool {
        guard Environment.StoreKit2.available else { return false }

        switch _storeKit2Usage {
        case .disabled: return false
        default: return true
        }
    }

    private static var _storeKit2Usage: StoreKit2Usage = .default

    static func setStoreKit2Usage(_ value: StoreKit2Usage) {
        _storeKit2Usage = value
    }
}
