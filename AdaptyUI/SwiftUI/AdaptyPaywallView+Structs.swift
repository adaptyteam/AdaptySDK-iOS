//
//  AdaptyPaywallView+Structs.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 20.09.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

struct FinishPurchaseInfo: Equatable {
    let product: AdaptyPaywallProduct
    let info: AdaptyPurchasedInfo

    static func == (lhs: FinishPurchaseInfo, rhs: FinishPurchaseInfo) -> Bool {
        lhs.product == rhs.product && lhs.info == rhs.info
    }
}

struct FailPurchaseInfo: Equatable {
    let product: AdaptyPaywallProduct
    let error: AdaptyError

    static func == (lhs: FailPurchaseInfo, rhs: FailPurchaseInfo) -> Bool {
        lhs.product == rhs.product && lhs.error == rhs.error
    }
}

extension AdaptyPaywallProduct: Equatable {
    public static func == (lhs: AdaptyPaywallProduct, rhs: AdaptyPaywallProduct) -> Bool {
        lhs.adaptyProductId == rhs.adaptyProductId
    }
}

extension AdaptyError: Equatable {
    public static func == (lhs: AdaptyError, rhs: AdaptyError) -> Bool {
        lhs.adaptyErrorCode == rhs.adaptyErrorCode
    }
}

extension AdaptyPurchasedInfo: Equatable {
    public static func == (lhs: AdaptyPurchasedInfo, rhs: AdaptyPurchasedInfo) -> Bool {
        lhs.profile == rhs.profile && lhs.transaction == rhs.transaction
    }
}

#endif

