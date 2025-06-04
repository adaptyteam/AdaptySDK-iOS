//
//  Adapty+Receipt.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

public extension Adapty {
    /// You can fetch the StoreKit receipt by calling this method
    ///
    /// If the receipt is not presented on the device, Adapty will try to refresh it by using [SKReceiptRefreshRequest](https://developer.apple.com/documentation/storekit/skreceiptrefreshrequest)
    ///
    /// - Returns: The receipt `Data`.
    /// - Throws: An ``AdaptyError`` object.
    nonisolated static func getReceipt() async throws -> Data {
        try await withActivatedSDK(methodName: .getReceipt) { sdk in
            try await sdk.receiptManager.getReceipt()
        }
    }
}
