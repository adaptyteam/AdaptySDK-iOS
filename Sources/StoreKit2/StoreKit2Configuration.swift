//
//  StoreKit2Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 9.05.2023
//

public enum StoreKit2Configuration {
    public static let `default`: Self = .disabled

    /// Adapty SDK will not use StoreKit 2 functionality.
    case disabled

    /// Adapty SDK will use StoreKit 2 functionality to determine introductory offers eligibility.
    case enableToDetermineIntroductoryOfferEligibility
}

extension Adapty.Configuration {
    static var enabledStoreKit2: Bool { enabledStoreKit2ProductsFetcher }

    static var enabledStoreKit2ProductsFetcher: Bool {
        guard Environment.StoreKit2.available else { return false }
        switch _useStoreKit2 {
        case .disabled: return false
        default: return true
        }
    }

    static var enabledStoreKit2TransactionObserver: Bool { Environment.StoreKit2.available }

    private static var _useStoreKit2: StoreKit2Configuration = .default
    static func setUseStoreKit2(_ value: StoreKit2Configuration) {
        _useStoreKit2 = value
    }
}
