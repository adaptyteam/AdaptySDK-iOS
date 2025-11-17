//
//  AdaptyPaywallPlatformViewWrapper.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

    import Adapty
    import AdaptyUI
    import UIKit

    public final class AdaptyPaywallPlatformViewWrapper: UIView {
        private let eventHandler: EventHandler
        private let paywallView: AdaptyPaywallUIView
        private let parentVC: UIViewController

        public init(
            viewId: String,
            eventHandler: EventHandler,
            configuration: AdaptyUI.PaywallConfiguration,
            parentVC: UIViewController
        ) {
            self.eventHandler = eventHandler
            self.parentVC = parentVC

            paywallView = AdaptyPaywallUIView(
                configuration: configuration,
                id: viewId
            )

            super.init(frame: .zero)

            layout()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func layout() {
            paywallView.configure(delegate: self)
            paywallView.layout(in: self, parentVC: parentVC)
            paywallView.reportOnAppear()
        }
    }

    @MainActor
    extension AdaptyPaywallPlatformViewWrapper: AdaptyPaywallViewDelegate {
        package func paywallViewDidAppear(_ view: AdaptyPaywallUIView) {
            eventHandler.handle(
                event: PaywallViewEvent.DidAppear(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func paywallViewDidDisappear(_ view: AdaptyPaywallUIView) {
            eventHandler.handle(
                event: PaywallViewEvent.DidDisappear(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didPerform action: AdaptyUI.Action
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidUserAction(
                    view: view.toAdaptyUIView(),
                    action: action
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidSelectProduct(
                    view: view.toAdaptyUIView(),
                    productVendorId: product.vendorProductId
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didStartPurchase product: AdaptyPaywallProduct
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.WillPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product)
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFinishPurchase product: AdaptyPaywallProduct,
            purchaseResult: AdaptyPurchaseResult
        ) {

            eventHandler.handle(
                event: PaywallViewEvent.DidPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product),
                    purchasedResult: purchaseResult
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFailPurchase product: AdaptyPaywallProduct,
            error: AdaptyError
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidFailPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product),
                    error: error
                )
            )
        }

        package func paywallViewDidStartRestore(_ view: AdaptyPaywallUIView) {
            eventHandler.handle(
                event: PaywallViewEvent.WillRestorePurchases(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFinishRestoreWith profile: AdaptyProfile
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidRestorePurchases(
                    view: view.toAdaptyUIView(),
                    profile: profile
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFailRestoreWith error: AdaptyError
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidFailRestorePurchases(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFailRenderingWith error: AdaptyUIError
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidFailRendering(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFailLoadingProductsWith error: AdaptyError
        ) -> Bool {
            eventHandler.handle(
                event: PaywallViewEvent.DidFailLoadingProducts(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
            return false
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didPartiallyLoadProducts failedIds: [String]
        ) {
//            eventHandler.handle(
//                event: PaywallViewEvent.DidPartiallyLoadProducts(
//                    view: view.toAdaptyUIView(),
//                    failedIds: failedIds
//                )
//            )
        }

        package func paywallView(
            _ view: AdaptyPaywallUIView,
            didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
            error: AdaptyError?
        ) {
            eventHandler.handle(
                event: PaywallViewEvent.DidFinishWebPaymentNavigation(
                    view: view.toAdaptyUIView(),
                    product: product.map(Response.AdaptyPluginPaywallProduct.init),
                    error: error
                )
            )
        }
    }

#endif
