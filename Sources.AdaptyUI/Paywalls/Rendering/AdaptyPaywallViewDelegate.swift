//
//  AdaptyflowViewDelegate.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

import Adapty
import UIKit

@MainActor
package protocol AdaptyFlowViewDelegate: AnyObject {
    func flowViewDidAppear(_ view: AdaptyFlowUIView)

    func flowViewDidDisappear(_ view: AdaptyFlowUIView)

    func flowView(
        _ view: AdaptyFlowUIView,
        didPerform action: AdaptyUI.Action
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didStartPurchase product: AdaptyPaywallProduct
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    )

    func flowViewDidStartRestore(_ view: AdaptyFlowUIView)

    func flowView(
        _ view: AdaptyFlowUIView,
        didFinishRestoreWith profile: AdaptyProfile
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFailRestoreWith error: AdaptyError
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFailRenderingWith error: AdaptyUIError
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool

    func flowView(
        _ view: AdaptyFlowUIView,
        didPartiallyLoadProducts failedIds: [String]
    )

    func flowView(
        _ view: AdaptyFlowUIView,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    )
}

#endif
