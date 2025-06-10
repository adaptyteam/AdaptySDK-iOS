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

#if canImport(UIKit)

import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPlugin {
    static let xibName = "AdaptyOnboardingPlaceholderView"
    
    static func instantiateOnboardingPlaceholderView() -> UIView? {
        guard Bundle.main.path(forResource: xibName, ofType: "nib") != nil else { return nil }
        
        return Bundle.main.loadNibNamed(
            xibName,
            owner: nil,
            options: nil
        )?.first as? UIView
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPluginDelegate: AdaptyPaywallControllerDelegate {
    func paywallControllerDidAppear(
        _ controller: AdaptyPaywallController
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidAppear(
            view: controller.toAdaptyUIView()
        ))
    }

    func paywallControllerDidDisappear(
        _ controller: AdaptyPaywallController
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidDisappear(
            view: controller.toAdaptyUIView()
        ))
    }

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
        didFailRenderingWith error: AdaptyUIError
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
        eventHandler.handle(event: PaywallViewEvent.DidFailLoadingProducts(
            view: controller.toAdaptyUIView(),
            error: error
        ))

        return true
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {
        eventHandler.handle(event: PaywallViewEvent.DidFinishWebPaymentNavigation(
            view: controller.toAdaptyUIView(),
            product: product.map(Response.AdaptyPluginPaywallProduct.init),
            error: error
        ))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPluginDelegate: AdaptyOnboardingControllerDelegate {
    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFinishLoading action: OnboardingsDidFinishLoadingAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.DidFinishLoading(
                view: controller.toAdaptyUIView(),
                action: action
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCloseAction action: AdaptyOnboardingsCloseAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnCloseAction(
                view: controller.toAdaptyUIView(),
                action: action
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onPaywallAction action: AdaptyOnboardingsOpenPaywallAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnPaywallAction(
                view: controller.toAdaptyUIView(),
                action: action
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onCustomAction action: AdaptyOnboardingsCustomAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnCustomAction(
                view: controller.toAdaptyUIView(),
                action: action
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onStateUpdatedAction action: AdaptyOnboardingsStateUpdatedAction
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnStateUpdatedAction(
                view: controller.toAdaptyUIView(),
                action: action
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        onAnalyticsEvent event: AdaptyOnboardingsAnalyticsEvent
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.OnAnalyticsAction(
                view: controller.toAdaptyUIView(),
                event: event
            )
        )
    }

    func onboardingController(
        _ controller: AdaptyOnboardingController,
        didFailWithError error: AdaptyUIError
    ) {
        eventHandler.handle(
            event: OnboardingViewEvent.DidFailWithError(
                view: controller.toAdaptyUIView(),
                error: error
            )
        )
    }

    func onboardingsControllerLoadingPlaceholder(
        _ controller: AdaptyOnboardingController
    ) -> UIView? {
        AdaptyPlugin.instantiateOnboardingPlaceholderView() ?? AdaptyOnboardingPlacehoderView()
    }
}

#endif
