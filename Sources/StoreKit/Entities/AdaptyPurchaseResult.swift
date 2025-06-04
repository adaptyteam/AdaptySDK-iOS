//
//  AdaptyPurchaseResult.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.06.2023
//

import StoreKit

public enum AdaptyPurchaseResult: Sendable {
    /// The user cancelled the purchase.
    case userCancelled
    /// The purchase is pending some user action.
    case pending
    /// The purchase succeeded with a `AdaptyProfile`.
    case success(profile: AdaptyProfile, transaction: any Sendable)

    @inlinable
    public var isPurchaseCancelled: Bool {
        if case .userCancelled = self {
            true
        } else {
            false
        }
    }

    @inlinable
    public var isPurchasePending: Bool {
        if case .pending = self {
            true
        } else {
            false
        }
    }

    @inlinable
    public var isPurchaseSuccess: Bool {
        if case .success = self {
            true
        } else {
            false
        }
    }

    /// An ``AdaptyProfile`` which contains the up-to-date inforation about the user.
    @inlinable
    public var profile: AdaptyProfile? {
        guard case let .success(profile, _) = self else {
            return nil
        }
        return profile
    }

    /// A transaction object, which represents the payment.
    public var sk1Transaction: SKPaymentTransaction? {
        guard case let .success(_, transaction) = self,
              let sk1Transaction = transaction as? SK1Transaction
        else {
            return nil
        }
        return sk1Transaction
    }

    /// A transaction object, which represents the payment.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public var sk2Transaction: Transaction? {
        guard case let .success(_, transaction) = self,
              let sk2Transaction = transaction as? SK2Transaction
        else {
            return nil
        }
        return sk2Transaction
    }
}
