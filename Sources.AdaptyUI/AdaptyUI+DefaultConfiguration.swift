//
//  AdaptyUI+DefaultConfiguration.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import UIKit

public extension AdaptyPaywallControllerDelegate {
    func paywallControllerDidAppear(_ controller: AdaptyPaywallController) {}

    func paywallControllerDidDisappear(_ controller: AdaptyPaywallController) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didPerform action: AdaptyUI.Action
    ) {
        switch action {
        case .close:
            controller.dismiss(animated: true)
        case let .openURL(url):
            UIApplication.shared.open(url, options: [:])
        case .custom:
            break
        }
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didSelectProduct product: any AdaptyPaywallProductWithoutDeterminingOffer
    ) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        if !purchaseResult.isPurchaseCancelled {
            controller.dismiss(animated: true)
        }
    }

    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRenderingWith error: AdaptyUIError
    ) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        false
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {}
}

#endif
