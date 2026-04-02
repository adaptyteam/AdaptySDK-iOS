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

public extension AdaptyFlowControllerDelegate {
    func paywallControllerDidAppear(_ controller: AdaptyFlowController) {}

    func paywallControllerDidDisappear(_ controller: AdaptyFlowController) {}

    func paywallController(
        _ controller: AdaptyFlowController,
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
        _ controller: AdaptyFlowController,
        didSelectProduct product: any AdaptyPaywallProductWithoutDeterminingOffer
    ) {}

    func paywallController(
        _ controller: AdaptyFlowController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {}

    func paywallController(
        _ controller: AdaptyFlowController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        if !purchaseResult.isPurchaseCancelled {
            controller.dismiss(animated: true)
        }
    }

    func paywallControllerDidStartRestore(_ controller: AdaptyFlowController) {}

    func paywallController(
        _ controller: AdaptyFlowController,
        didFailRenderingWith error: AdaptyUIError
    ) {}

    func paywallController(
        _ controller: AdaptyFlowController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        false
    }

    func paywallController(
        _ controller: AdaptyFlowController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}

    func paywallController(
        _ controller: AdaptyFlowController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {}
}

#endif
