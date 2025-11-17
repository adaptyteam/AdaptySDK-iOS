//
//  AdaptyPaywallViewDelegate.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

import Adapty
import UIKit

@MainActor
package protocol AdaptyPaywallViewDelegate: AnyObject {
    func paywallViewDidAppear(_ view: AdaptyPaywallUIView)

    func paywallViewDidDisappear(_ view: AdaptyPaywallUIView)

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didPerform action: AdaptyUI.Action
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didStartPurchase product: AdaptyPaywallProduct
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    )

    func paywallViewDidStartRestore(_ view: AdaptyPaywallUIView)

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishRestoreWith profile: AdaptyProfile
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailRestoreWith error: AdaptyError
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailRenderingWith error: AdaptyUIError
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didPartiallyLoadProducts failedIds: [String]
    )

    func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    )
}

#endif
