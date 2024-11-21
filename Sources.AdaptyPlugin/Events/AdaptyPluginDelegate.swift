//
//  AdaptyPluginDelegate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI

private let log = Log.plugin

final class AdaptyPluginDelegate {
    let eventHandler: EventHandler

    init(eventHandler: EventHandler) {
        self.eventHandler = eventHandler
    }
}

extension AdaptyPluginDelegate: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        eventHandler.handle(event: Event.DidLoadLatestProfile(
            profile: profile
        ))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPluginDelegate: AdaptyPaywallControllerDelegate {
    func paywallController(
        _ controller: AdaptyPaywallController,
        didPerform action: AdaptyUI.Action
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidUserAction(
            view: controller.toAdaptyUIView(),
            action: action
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidSelectProduct(
            view: controller.toAdaptyUIView(),
            productVendorId: product.vendorProductId
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {
        eventHandler.handle(event: PaywallViewEvent.WillPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product)
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product),
            purchasedResult: purchaseResult
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidFailPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product),
            error: error
        ))
    }

    func paywallControllerDidStartRestore(
        _ controller: AdaptyPaywallController
    ) {
        eventHandler.handle(event: PaywallViewEvent.WillRestorePurchases(
            view: controller.toAdaptyUIView()
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishRestoreWith profile: AdaptyProfile
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidRestorePurchases(
            view: controller.toAdaptyUIView(),
            profile: profile
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRestoreWith error: AdaptyError
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidFailRestorePurchases(
            view: controller.toAdaptyUIView(),
            error: error
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRenderingWith error: AdaptyError
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidFailRendering(
            view: controller.toAdaptyUIView(),
            error: error
        ))
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        eventHandler.handle(event: PaywallViewEvent.DidFailRendering(
            view: controller.toAdaptyUIView(),
            error: error
        ))

        return true
    }
}
