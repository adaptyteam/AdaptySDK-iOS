//
//  Adapty+presentCodeRedemptionSheet.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

extension Adapty {
    /// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by your app.
    public static func presentCodeRedemptionSheet() {
        let logName = "present_code_redemption_sheet"
        #if (os(iOS) || os(visionOS)) && !targetEnvironment(macCatalyst)
            async(nil, logName: logName) { _, completion in
                if #available(iOS 14.0, visionOS 1.0, *) {
                    SKPaymentQueue.default().presentCodeRedemptionSheet()
                } else {
                    Log.error("Presenting code redemption sheet is available only for iOS 14 and higher.")
                }
                completion(nil)
            }
        #else
            let stamp = Log.stamp
            Adapty.logSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, callId: stamp))
            Adapty.logSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, callId: stamp, error: "not available"))
        #endif
    }
}
