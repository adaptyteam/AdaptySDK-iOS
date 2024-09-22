//
//  AdaptyDelegate.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public protocol AdaptyDelegate: AnyObject, Sendable {
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
    public weak static var delegate: AdaptyDelegate?

    /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
    public static func setDelegate(_ delegate: AdaptyDelegate) {
        self.delegate = delegate
    }

    nonisolated static func callDelegate(_ call: @Sendable @escaping (AdaptyDelegate) -> Void) {
        Task.detached {
            guard let delegate = await Adapty.delegate else { return }
            call(delegate)
        }
    }
}
