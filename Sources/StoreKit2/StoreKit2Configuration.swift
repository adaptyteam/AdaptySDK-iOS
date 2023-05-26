//
//  StoreKit2Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 9.05.2023
//

/// Defines StoreKit 2 utilization behaviour.
public enum StoreKitConfiguration {
    public static let `default`: Self = .useStoreKit1

    /// Adapty will never use StoreKit 2.
    case useStoreKit1

    /// Adapty will use StoreKit 2 functionality to optimize some features.
    ///
    /// For now it can be used only to determine introductory offers eligibility.
    ///
    /// Note, that StoreKit 2 is only available with iOS 15.0 and newer.
    case useStoreKit2ForOptimizations
}

extension Adapty.Configuration {
    static var enabledStoreKit2: Bool { enabledStoreKit2ProductsFetcher }

    static var enabledStoreKit2ProductsFetcher: Bool {
        guard Environment.StoreKit2.available else { return false }

        switch _storeKitConfiguration {
        case .useStoreKit1: return false
        default: return true
        }
    }

    private static var _storeKitConfiguration: StoreKitConfiguration = .default

    static func setStoreKitConfiguration(_ value: StoreKitConfiguration) {
        _storeKitConfiguration = value
    }
}
