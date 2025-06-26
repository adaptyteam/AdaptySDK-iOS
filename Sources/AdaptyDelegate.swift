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

    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails)

    func onInstallationDetailsFail(error: AdaptyError)
}

public extension AdaptyDelegate {
    func shouldAddStorePayment(for _: AdaptyDeferredProduct) -> Bool { true }
    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails) {}
    func onInstallationDetailsFail(error: AdaptyError) {}
}

extension Adapty {
    /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
    public nonisolated(unsafe) static var delegate: AdaptyDelegate?

    static func callDelegate(_ call: @Sendable @escaping (AdaptyDelegate) -> Void) {
        guard let delegate = Adapty.delegate else { return }
        let queue = AdaptyConfiguration.callbackDispatchQueue ?? .main
        queue.async {
            call(delegate)
        }
    }
}
