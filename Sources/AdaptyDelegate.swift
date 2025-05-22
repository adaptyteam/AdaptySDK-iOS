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
    func shouldAddStorePayment(for product: AdaptyDeferredProduct) -> Bool
}

public extension AdaptyDelegate {
    func shouldAddStorePayment(for _: AdaptyDeferredProduct) -> Bool { true }
}

extension Adapty {
    #if compiler(>=5.10)
        /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
        public nonisolated(unsafe) static var delegate: AdaptyDelegate?
    #else
        /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
        public nonisolated static var delegate: AdaptyDelegate? {
            get { _nonisolatedUnsafe.delegate }
            set { _nonisolatedUnsafe.delegate = newValue }
        }

        private final class NonisolatedUnsafe: @unchecked Sendable {
            weak var delegate: AdaptyDelegate?
        }

        private nonisolated static let _nonisolatedUnsafe = NonisolatedUnsafe()
    #endif

    static func callDelegate(_ call: @Sendable @escaping (AdaptyDelegate) -> Void) {
        guard let delegate = Adapty.delegate else { return }
        let queue = AdaptyConfiguration.callbackDispatchQueue ?? .main
        queue.async {
            call(delegate)
        }
    }
}
