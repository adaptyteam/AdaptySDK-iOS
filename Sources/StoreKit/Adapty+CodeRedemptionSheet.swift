//
//  Adapty+CodeRedemptionSheet.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

private let log = Log.default

public extension Adapty {
    /// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by your app.
    nonisolated static func presentCodeRedemptionSheet() {
        Task.detached { @MainActor in
            let stamp = Log.stamp
            let name = MethodName.presentCodeRedemptionSheet
            var error: String?

            Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: name, stamp: stamp))

            #if (os(iOS) || os(visionOS)) && !targetEnvironment(macCatalyst)
            SKPaymentQueue.default().presentCodeRedemptionSheet()
            #else
            error = "Presenting code redemption sheet is available only for iOS 14 and higher."
            #endif

            if let error { log.error(error) }
            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: name, stamp: stamp, error: error))
        }
    }
}
