//
//  AdaptyDelegate.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public protocol AdaptyDelegate: AnyObject {
    /// Implement this delegate method to receive automatic profile updates
    func didLoadLatestProfile(_ profile: Profile)

    /// Implement this delegate method to handle a [user initiated an in-app purchases](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue) from the App Store.
    func paymentQueue(shouldAddStorePaymentFor product: DeferredProduct, defermentCompletion makeDeferredPurchase: @escaping (ResultCompletion<Profile>?) -> Void)
}

extension Adapty {
    /// Set the delegate to listen for `Profile` updates and user initiated an in-app purchases
    public weak static var delegate: AdaptyDelegate?
}

extension Adapty {
    static func callDelegate(_ call: @escaping (AdaptyDelegate) -> Void) {
        (dispatchQueue ?? .main).async {
            guard let delegate = delegate else { return }
            call(delegate)
        }
    }
}
