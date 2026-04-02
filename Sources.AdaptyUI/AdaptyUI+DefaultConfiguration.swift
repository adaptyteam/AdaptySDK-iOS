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
    func flowControllerDidAppear(_ controller: AdaptyFlowController) {}

    func flowControllerDidDisappear(_ controller: AdaptyFlowController) {}

    func flowController(
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

    func flowController(
        _ controller: AdaptyFlowController,
        didSelectProduct product: any AdaptyPaywallProductWithoutDeterminingOffer
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        if !purchaseResult.isPurchaseCancelled {
            controller.dismiss(animated: true)
        }
    }

    func flowControllerDidStartRestore(_ controller: AdaptyFlowController) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFailRenderingWith error: AdaptyUIError
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        false
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {}
}

#endif
