//
//  AdaptyPluginDelegate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty
import AdaptyUI
import AdaptyUIBuilder

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

    func onInstallationDetailsSuccess(_ details: AdaptyInstallationDetails) {
        eventHandler.handle(event: Event.OnInstallationDetailsSuccess(
            details: details
        ))
    }

    func onInstallationDetailsFail(error: AdaptyError) {
        eventHandler.handle(event: Event.OnInstallationDetailsFail(
            error: error
        ))
    }
}

#if canImport(UIKit)

import UIKit

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

extension AdaptyPluginDelegate: AdaptyFlowControllerDelegate {
    func flowControllerDidAppear(
        _ controller: AdaptyFlowController
    ) {
        eventHandler.handle(event: FlowViewEvent.DidAppear(
            view: controller.toAdaptyUIView()
        ))
    }

    func flowControllerDidDisappear(
        _ controller: AdaptyFlowController
    ) {
        eventHandler.handle(event: FlowViewEvent.DidDisappear(
            view: controller.toAdaptyUIView()
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didPerform action: AdaptyUI.Action
    ) {
        eventHandler.handle(event: FlowViewEvent.DidUserAction(
            view: controller.toAdaptyUIView(),
            action: action
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    ) {
        eventHandler.handle(event: FlowViewEvent.DidSelectProduct(
            view: controller.toAdaptyUIView(),
            productVendorId: product.vendorProductId
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didStartPurchase product: AdaptyPaywallProduct
    ) {
        eventHandler.handle(event: FlowViewEvent.WillPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product)
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        eventHandler.handle(event: FlowViewEvent.DidPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product),
            purchasedResult: purchaseResult
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        eventHandler.handle(event: FlowViewEvent.DidFailPurchase(
            view: controller.toAdaptyUIView(),
            product: Response.AdaptyPluginPaywallProduct(product),
            error: error
        ))
    }

    func flowControllerDidStartRestore(
        _ controller: AdaptyFlowController
    ) {
        eventHandler.handle(event: FlowViewEvent.WillRestorePurchases(
            view: controller.toAdaptyUIView()
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishRestoreWith profile: AdaptyProfile
    ) {
        eventHandler.handle(event: FlowViewEvent.DidRestorePurchases(
            view: controller.toAdaptyUIView(),
            profile: profile
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFailRestoreWith error: AdaptyError
    ) {
        eventHandler.handle(event: FlowViewEvent.DidFailRestorePurchases(
            view: controller.toAdaptyUIView(),
            error: error
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFailRenderingWith error: AdaptyUIError
    ) {
        eventHandler.handle(event: FlowViewEvent.DidFailRendering(
            view: controller.toAdaptyUIView(),
            error: error
        ))
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        eventHandler.handle(event: FlowViewEvent.DidFailLoadingProducts(
            view: controller.toAdaptyUIView(),
            error: error
        ))

        return true
    }

    func flowController(
        _ controller: AdaptyFlowController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}

    func flowController(
        _ controller: AdaptyFlowController,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {
        eventHandler.handle(event: FlowViewEvent.DidFinishWebPaymentNavigation(
            view: controller.toAdaptyUIView(),
            product: product.map(Response.AdaptyPluginPaywallProduct.init),
            error: error
        ))
    }
}

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
