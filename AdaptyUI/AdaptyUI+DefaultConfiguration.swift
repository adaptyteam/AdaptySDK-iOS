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
extension AdaptyPaywallControllerDelegate {
    public func paywallController(
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

    public func paywallController(
        _ controller: AdaptyPaywallController,
        didSelectProduct product: AdaptyPaywallProduct
    ) {
    }

    public func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyPaywallProduct,
                                  purchasedInfo: AdaptyPurchasedInfo) {
        controller.dismiss(animated: true)
    }
    
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didCancelPurchase product: AdaptyPaywallProduct
    ) {
    }

    public func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
    }
    
    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith error: AdaptyError) -> Bool {
        false
    }
}

#endif
