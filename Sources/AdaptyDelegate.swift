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

    func didReceivePromotedPurchase(_ product: AdaptyPromotedProduct)

    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails)

    func onInstallationDetailsFail(error: AdaptyError)

    func onUnfinishedTransaction(_ adaptyUnfinishedTransaction: AdaptyUnfinishedTransaction)
}

public extension AdaptyDelegate {
    @inlinable
    func didReceivePromotedPurchase(_ product: AdaptyPromotedProduct) {
        Task {
            _ = try? await Adapty.makePurchase(product: product)
        }
    }

    func onInstallationDetailsSuccess(_: AdaptyInstallationDetails) {}
    func onInstallationDetailsFail(error _: AdaptyError) {}

    func onUnfinishedTransaction(_: AdaptyUnfinishedTransaction) {}
}

extension Adapty {
    /// Set the delegate to listen for `AdaptyProfile` updates and user initiated an in-app purchases
    public nonisolated(unsafe) static var delegate: AdaptyDelegate?

    @discardableResult
    static func callDelegate(_ call: @Sendable @escaping (AdaptyDelegate) -> Void) -> Bool {
        guard let delegate = Adapty.delegate else { return false }
        let queue = AdaptyConfiguration.callbackDispatchQueue ?? .main
        queue.async {
            call(delegate)
        }
        return true
    }
}
