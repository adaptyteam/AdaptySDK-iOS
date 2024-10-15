//
//  AdaptyUI+DefaultConfiguration.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, *)
public extension AdaptyPaywallControllerDelegate {
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
        didSelectProduct underlying: AdaptyPaywallProduct
    ) {}

    func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase underlying: AdaptyPaywallProduct
    ) {}

    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase underlying: AdaptyPaywallProduct,
                           purchasedInfo: AdaptyPurchasedInfo)
    {
        controller.dismiss(animated: true)
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didCancelPurchase underlying: AdaptyPaywallProduct
    ) {}

    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {}

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRenderingWith error: AdaptyError) {}

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailLoadingProductsWith error: AdaptyError) -> Bool
    {
        false
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}
}

#endif
