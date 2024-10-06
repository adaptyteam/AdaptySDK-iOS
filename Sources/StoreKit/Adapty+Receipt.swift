//
//  Adapty+Receipt.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import Foundation

extension Adapty {
    /// You can fetch the StoreKit receipt by calling this method
    ///
    /// If the receipt is not presented on the device, Adapty will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
    ///
    /// - Returns: The receipt `Data`.
    /// - Throws: An ``AdaptyError`` object.
    public nonisolated static func getReceipt() async throws -> Data {
        try await withActivatedSDK(methodName: .getReceipt) { sdk in
            try await sdk.receiptManager.getReceipt()
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Returns: The ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func restorePurchases() async throws -> AdaptyProfile {
        try await withActivatedSDK(methodName: .restorePurchases) { sdk in
            let profileId = sdk.profileStorage.profileId
            if let response = try await sdk.transactionManager.syncTransactions(for: profileId) {
                return response.value
            }

            let manager = try await sdk.createdProfileManager
            if manager.profileId != profileId {
                throw AdaptyError.profileWasChanged()
            }

            return await manager.getProfile()
        }
    }
}
