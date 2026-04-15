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
    func flowControllerDidAppear(_: AdaptyFlowController) {}

    func flowControllerDidDisappear(_: AdaptyFlowController) {}

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
        _: AdaptyFlowController,
        didSelectProduct _: AdaptyPaywallProduct
    ) {}

    func flowController(
        _: AdaptyFlowController,
        didStartPurchase _: AdaptyPaywallProduct
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishPurchase _: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        if !purchaseResult.isPurchaseCancelled {
            controller.dismiss(animated: true)
        }
    }

    func flowControllerDidStartRestore(_: AdaptyFlowController) {}

    func flowController(
        _: AdaptyFlowController,
        didFailRenderingWith _: AdaptyUIError
    ) {}

    func flowController(
        _: AdaptyFlowController,
        didFailLoadingProductsWith _: AdaptyError
    ) -> Bool {
        false
    }

    func flowController(
        _: AdaptyFlowController,
        didPartiallyLoadProducts _: [String]
    ) {}

    func flowController(
        _: AdaptyFlowController,
        didFinishWebPaymentNavigation _: AdaptyPaywallProduct?,
        error _: AdaptyError?
    ) {}

    func flowController(
        _: AdaptyFlowController,
        didReceiveAnalyticEvent _: String,
        params _: [String: any Sendable]
    ) {}
}

#endif
