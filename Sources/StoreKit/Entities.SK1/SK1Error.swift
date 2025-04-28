//
//  SK1Error.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

typealias SK1Error = SKError

extension SK1Error {
    @inlinable
    var isPurchaseCancelled: Bool {
        (code == .paymentCancelled) || (code == .overlayCancelled)
    }
}
