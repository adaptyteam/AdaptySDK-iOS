//
//  StoreKit2Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 9.05.2023
//

public enum StoreKit2Configuration {
    public static let `default`: Self = .disabled

    case disabled
    case enableForCheckIntroductoryOfferEligibility
}

extension Adapty.Configuration {
    static var enabledStoreKit2: Bool { enabledStoreKit2ProductsFetcher }

    static var enabledStoreKit2ProductsFetcher: Bool {
        guard Environment.StoreKit2.available else { return false }
        switch _usingStoreKit2 {
        case .disabled: return false
        default: return true
        }
    }

    private static var _usingStoreKit2: StoreKit2Configuration = .default
    static func setUsingStoreKit2(_ value: StoreKit2Configuration) {
        _usingStoreKit2 = value
    }
}
