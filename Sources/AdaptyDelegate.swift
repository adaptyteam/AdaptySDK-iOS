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

    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails)

    func onInstallationDetailsFail(error: AdaptyError)

    func onUnfinishedTransaction(_ adaptyUnfinishedTransaction: AdaptyUnfinishedTransaction)
}

public extension AdaptyDelegate {
    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails) {}
    func onInstallationDetailsFail(error: AdaptyError) {}

    func onUnfinishedTransaction(_ adaptyUnfinishedTransaction: AdaptyUnfinishedTransaction) {}
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
