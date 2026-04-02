//
//  AdaptyFlowPlatformViewWrapper.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

    import Adapty
    import AdaptyUI
    import UIKit

    public final class AdaptyFlowPlatformViewWrapper: UIView {
        private let eventHandler: EventHandler
        private let flowView: AdaptyFlowUIView
        private let parentVC: UIViewController

        public init(
            viewId: String,
            eventHandler: EventHandler,
            configuration: AdaptyUI.FlowConfiguration,
            parentVC: UIViewController
        ) {
            self.eventHandler = eventHandler
            self.parentVC = parentVC

            flowView = AdaptyFlowUIView(
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
            flowView.configure(delegate: self)
            flowView.layout(in: self, parentVC: parentVC)
            flowView.reportOnAppear()
        }
    }

    @MainActor
    extension AdaptyFlowPlatformViewWrapper: AdaptyFlowViewDelegate {
        package func flowViewDidAppear(_ view: AdaptyFlowUIView) {
            eventHandler.handle(
                event: FlowViewEvent.DidAppear(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func flowViewDidDisappear(_ view: AdaptyFlowUIView) {
            eventHandler.handle(
                event: FlowViewEvent.DidDisappear(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didPerform action: AdaptyUI.Action
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidUserAction(
                    view: view.toAdaptyUIView(),
                    action: action
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidSelectProduct(
                    view: view.toAdaptyUIView(),
                    productVendorId: product.vendorProductId
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didStartPurchase product: AdaptyPaywallProduct
        ) {
            eventHandler.handle(
                event: FlowViewEvent.WillPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product)
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFinishPurchase product: AdaptyPaywallProduct,
            purchaseResult: AdaptyPurchaseResult
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product),
                    purchasedResult: purchaseResult
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFailPurchase product: AdaptyPaywallProduct,
            error: AdaptyError
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidFailPurchase(
                    view: view.toAdaptyUIView(),
                    product: Response.AdaptyPluginPaywallProduct(product),
                    error: error
                )
            )
        }

        package func flowViewDidStartRestore(_ view: AdaptyFlowUIView) {
            eventHandler.handle(
                event: FlowViewEvent.WillRestorePurchases(
                    view: view.toAdaptyUIView()
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFinishRestoreWith profile: AdaptyProfile
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidRestorePurchases(
                    view: view.toAdaptyUIView(),
                    profile: profile
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFailRestoreWith error: AdaptyError
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidFailRestorePurchases(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFailRenderingWith error: AdaptyUIError
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidFailRendering(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFailLoadingProductsWith error: AdaptyError
        ) -> Bool {
            eventHandler.handle(
                event: FlowViewEvent.DidFailLoadingProducts(
                    view: view.toAdaptyUIView(),
                    error: error
                )
            )
            return false
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didPartiallyLoadProducts failedIds: [String]
        ) {
//            eventHandler.handle(
//                event: FlowViewEvent.DidPartiallyLoadProducts(
//                    view: view.toAdaptyUIView(),
//                    failedIds: failedIds
//                )
//            )
        }

        package func flowView(
            _ view: AdaptyFlowUIView,
            didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
            error: AdaptyError?
        ) {
            eventHandler.handle(
                event: FlowViewEvent.DidFinishWebPaymentNavigation(
                    view: view.toAdaptyUIView(),
                    product: product.map(Response.AdaptyPluginPaywallProduct.init),
                    error: error
                )
            )
        }
    }

#endif
