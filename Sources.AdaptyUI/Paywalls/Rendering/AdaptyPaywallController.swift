//
//  AdaptyPaywallController.swift
//
//
//  Created by Alexey Goncharov on 2023-01-17.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import SwiftUI
import UIKit

@MainActor
public extension AdaptyPaywallController {
    var paywallPlacementId: String { configuration.paywallPlacementId }

    var paywallVariationId: String { configuration.paywallVariationId }
}

extension AdaptyUI.PaywallConfiguration {
    var paywallPlacementId: String {
        guard
            let logic = paywallViewModel.logic as? AdaptyUILogic
        else {
            return "unknown"
        }

        return logic.paywall.placement.id
    }

    var paywallVariationId: String {
        guard
            let logic = paywallViewModel.logic as? AdaptyUILogic
        else {
            return "unknown"
        }

        return logic.paywall.variationId
    }
}

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

//<<<<<<< HEAD:Sources.AdaptyUI/Paywalls/Rendering/AdaptyPaywallController.swift
        view.backgroundColor = .systemBackground

//        paywallConfiguration.eventsHandler.didAppear = { [weak self] in
//            guard let self else { return }
//            self.delegate?.paywallControllerDidAppear(self)
//        }
//
//        paywallConfiguration.eventsHandler.didDisappear = { [weak self] in
//            guard let self else { return }
//            self.delegate?.paywallControllerDidDisappear(self)
//        }
//
//        paywallConfiguration.eventsHandler.didPerformAction = { [weak self] action in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didPerform: action)
//        }
//
//        paywallConfiguration.eventsHandler.didSelectProduct = { [weak self] underlying in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didSelectProduct: underlying)
//        }
//
//        paywallConfiguration.eventsHandler.didStartPurchase = { [weak self] underlying in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didStartPurchase: underlying)
//        }
//
//        paywallConfiguration.eventsHandler.didFinishPurchase = { [weak self] underlying, purchaseResult in
//            guard let self else { return }
//            self.delegate?.paywallController(
//                self,
//                didFinishPurchase: underlying,
//                purchaseResult: purchaseResult
//            )
//        }
//
//        paywallConfiguration.eventsHandler.didFailPurchase = { [weak self] underlying, error in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didFailPurchase: underlying, error: error)
//        }
//
//        paywallConfiguration.eventsHandler.didStartRestore = { [weak self] in
//            guard let self else { return }
//            self.delegate?.paywallControllerDidStartRestore(self)
//        }
//
//        paywallConfiguration.eventsHandler.didFinishRestore = { [weak self] profile in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didFinishRestoreWith: profile)
//        }
//
//        paywallConfiguration.eventsHandler.didFailRestore = { [weak self] error in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didFailRestoreWith: error)
//        }
//
//        paywallConfiguration.eventsHandler.didFailRendering = { [weak self] error in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didFailRenderingWith: error)
//        }
//
//        paywallConfiguration.eventsHandler.didFailLoadingProducts = { [weak self] error in
//            guard let self else { return false }
//            guard let delegate = self.delegate else { return true }
//            return delegate.paywallController(self, didFailLoadingProductsWith: error)
//        }
//
//        paywallConfiguration.eventsHandler.didPartiallyLoadProducts = { [weak self] failedIds in
//            guard let self else { return }
//            self.delegate?.paywallController(self, didPartiallyLoadProducts: failedIds)
//        }
//
//        paywallConfiguration.eventsHandler.didFinishWebPaymentNavigation = { [weak self] product, error in
//            guard let self else { return }
//
//            self.delegate?.paywallController(
//                self,
//                didFinishWebPaymentNavigation: product,
//                error: error
//            )
//        }
//
//        addSubSwiftUIView(
//            AdaptyUIPaywallView_Internal(
//                showDebugOverlay: showDebugOverlay
//            )
//            .environmentObject(paywallConfiguration.eventsHandler)
//            .environmentObject(paywallConfiguration.paywallViewModel)
//            .environmentObject(paywallConfiguration.productsViewModel)
//            .environmentObject(paywallConfiguration.actionsViewModel)
//            .environmentObject(paywallConfiguration.sectionsViewModel)
//            .environmentObject(paywallConfiguration.tagResolverViewModel)
//            .environmentObject(paywallConfiguration.timerViewModel)
//            .environmentObject(paywallConfiguration.screensViewModel)
//            .environmentObject(paywallConfiguration.assetsViewModel),
//            to: view
//        )
//=======
        paywallView.configure(delegate: self)
        paywallView.layout(in: view, parentVC: self)
//>>>>>>> origin/release/3.12.0:AdaptyUI/Rendering/Wrappers/AdaptyPaywallController.swift

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
