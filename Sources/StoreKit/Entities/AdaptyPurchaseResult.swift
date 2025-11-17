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

    public var sk2SignedTransaction: VerificationResult<Transaction>? {
        guard case let .success(_, transaction) = self,
              let result = transaction as? VerificationResult<Transaction>
        else {
            return nil
        }
        return result
    }

    /// A transaction object, which represents the payment.
    public var sk2Transaction: Transaction? {
        sk2SignedTransaction?.unsafePayloadValue
    }
    
    public var jwsTransaction: String? {
        sk2SignedTransaction?.jwsRepresentation
    }
}
