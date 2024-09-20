//
//  AdaptyDelegate.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public protocol AdaptyDelegate: AnyObject {
    /// Implement this delegate method to receive automatic profile updates
    func didLoadLatestProfile(_ profile: AdaptyProfile)

    /// Implement this delegate method to handle a [user initiated an in-app purchases](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue) from the App Store.
    /// The default implementation returns `true`.
    ///
    /// Return `true` to continue the transaction in your app.
    /// Return `false` to defer or cancel the transaction.
    ///
    /// If you return `false`, you can continue the transaction later by manually calling the `defermentCompletion`.
    func shouldAddStorePayment(for product: AdaptyProduct, defermentCompletion makeDeferredPurchase: @escaping (AdaptyResultCompletion<AdaptyPurchasedInfo>?) -> Void) -> Bool
}

extension AdaptyDelegate {
    public func shouldAddStorePayment(for _: AdaptyProduct, defermentCompletion _: @escaping (AdaptyResultCompletion<AdaptyPurchasedInfo>?) -> Void) -> Bool {
        true
    }
}

extension Adapty {
    private final class MutableState: @unchecked Sendable {
        weak var delegate: AdaptyDelegate?
    }

    private static let current = MutableState()

    /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
    static var delegate: AdaptyDelegate? {
        get { current.delegate }
        set { current.delegate = newValue }
    }

    nonisolated static func callDelegate(_ call: @Sendable @escaping (AdaptyDelegate) -> Void) {
        Task.detached {
            guard let delegate else { return }
            call(delegate)
        }
    }
}
