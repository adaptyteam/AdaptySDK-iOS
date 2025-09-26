//
//  AdaptyPaywallController.swift
//
//
//  Created by Alexey Goncharov on 2023-01-17.
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension AdaptyPaywallController {
    var paywallPlacementId: String {
        paywallView.configuration.paywallViewModel.paywall.placementId
    }

    var paywallVariationId: String {
        paywallView.configuration.paywallViewModel.paywall.variationId
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public final class AdaptyPaywallController: UIViewController {
    public var id: String { paywallView.id }
    
    var configuration: AdaptyUI.PaywallConfiguration { paywallView.configuration }
    
    private let logId: String

    let showDebugOverlay: Bool

    private let paywallView: AdaptyPaywallUIView
    public weak var delegate: AdaptyPaywallControllerDelegate?

    init(
        paywallConfiguration: AdaptyUI.PaywallConfiguration,
        delegate: AdaptyPaywallControllerDelegate?,
        showDebugOverlay: Bool
    ) {
        self.delegate = delegate
        self.showDebugOverlay = showDebugOverlay

        paywallView = AdaptyPaywallUIView(
            configuration: paywallConfiguration,
            showDebugOverlay: false
        )
        
        logId = paywallConfiguration.eventsHandler.logId

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    deinit {
        Log.ui.verbose("#\(logId)# deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        Log.ui.verbose("#\(logId)# viewDidLoad begin")

        paywallView.configure(delegate: self)
        paywallView.layout(in: view, parentVC: self)

        Log.ui.verbose("#\(logId)# viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Log.ui.verbose("#\(logId)# viewDidAppear")

        paywallView.reportOnAppear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        Log.ui.verbose("#\(logId)# viewDidDisappear")

        paywallView.reportOnDisappear()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPaywallController: AdaptyPaywallViewDelegate {
    package func paywallViewDidAppear(_ view: AdaptyPaywallUIView) {
        delegate?.paywallControllerDidAppear(self)
    }

    package func paywallViewDidDisappear(_ view: AdaptyPaywallUIView) {
        delegate?.paywallControllerDidDisappear(self)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didPerform action: AdaptyUI.Action
    ) {
        delegate?.paywallController(self, didPerform: action)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    ) {
        delegate?.paywallController(self, didSelectProduct: product)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didStartPurchase product: AdaptyPaywallProduct
    ) {
        delegate?.paywallController(self, didStartPurchase: product)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        delegate?.paywallController(self, didFinishPurchase: product, purchaseResult: purchaseResult)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        delegate?.paywallController(self, didFailPurchase: product, error: error)
    }

    package func paywallViewDidStartRestore(_ view: AdaptyPaywallUIView) {
        delegate?.paywallControllerDidStartRestore(self)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishRestoreWith profile: AdaptyProfile
    ) {
        delegate?.paywallController(self, didFinishRestoreWith: profile)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailRestoreWith error: AdaptyError
    ) {
        delegate?.paywallController(self, didFailRestoreWith: error)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailRenderingWith error: AdaptyUIError
    ) {
        delegate?.paywallController(self, didFailRenderingWith: error)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        delegate?.paywallController(self, didFailLoadingProductsWith: error) ?? true
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didPartiallyLoadProducts failedIds: [String]
    ) {
        delegate?.paywallController(self, didPartiallyLoadProducts: failedIds)
    }

    package func paywallView(
        _ view: AdaptyPaywallUIView,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {
        delegate?.paywallController(self, didFinishWebPaymentNavigation: product, error: error)
    }
}

#endif
