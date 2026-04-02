//
//  AdaptyFlowController.swift
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
public extension AdaptyFlowController {
    var paywallPlacementId: String { configuration.paywallPlacementId }

    var paywallVariationId: String { configuration.paywallVariationId }
}

extension AdaptyUI.FlowConfiguration {
    var paywallPlacementId: String {
        guard
            let logic = flowViewModel.logic as? AdaptyUILogic
        else {
            return "unknown"
        }

        return logic.flow.placement.id
    }

    var paywallVariationId: String {
        guard
            let logic = flowViewModel.logic as? AdaptyUILogic
        else {
            return "unknown"
        }

        return logic.flow.variationId
    }
}

public final class AdaptyFlowController: UIViewController {
    public var id: String { flowView.id }

    var configuration: AdaptyUI.FlowConfiguration { flowView.configuration }

    private let logId: String

    let showDebugOverlay: Bool

    private let flowView: AdaptyFlowUIView
    public weak var delegate: AdaptyFlowControllerDelegate?

    init(
        paywallConfiguration: AdaptyUI.FlowConfiguration,
        delegate: AdaptyFlowControllerDelegate?,
        showDebugOverlay: Bool
    ) {
        self.delegate = delegate
        self.showDebugOverlay = showDebugOverlay

        flowView = AdaptyFlowUIView(
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

        view.backgroundColor = .systemBackground

        flowView.configure(delegate: self)
        flowView.layout(in: view, parentVC: self)

        Log.ui.verbose("#\(logId)# viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Log.ui.verbose("#\(logId)# viewDidAppear")

        flowView.reportOnAppear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        Log.ui.verbose("#\(logId)# viewDidDisappear")

        flowView.reportOnDisappear()
    }
}

extension AdaptyFlowController: AdaptyFlowViewDelegate {
    package func flowViewDidAppear(_ view: AdaptyFlowUIView) {
        delegate?.flowControllerDidAppear(self)
    }

    package func flowViewDidDisappear(_ view: AdaptyFlowUIView) {
        delegate?.flowControllerDidDisappear(self)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didPerform action: AdaptyUI.Action
    ) {
        delegate?.flowController(self, didPerform: action)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didSelectProduct product: AdaptyPaywallProduct
    ) {
        delegate?.flowController(self, didSelectProduct: product)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didStartPurchase product: AdaptyPaywallProduct
    ) {
        delegate?.flowController(self, didStartPurchase: product)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    ) {
        delegate?.flowController(self, didFinishPurchase: product, purchaseResult: purchaseResult)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        delegate?.flowController(self, didFailPurchase: product, error: error)
    }

    package func flowViewDidStartRestore(_ view: AdaptyFlowUIView) {
        delegate?.flowControllerDidStartRestore(self)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFinishRestoreWith profile: AdaptyProfile
    ) {
        delegate?.flowController(self, didFinishRestoreWith: profile)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFailRestoreWith error: AdaptyError
    ) {
        delegate?.flowController(self, didFailRestoreWith: error)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFailRenderingWith error: AdaptyUIError
    ) {
        delegate?.flowController(self, didFailRenderingWith: error)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool {
        delegate?.flowController(self, didFailLoadingProductsWith: error) ?? true
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didPartiallyLoadProducts failedIds: [String]
    ) {
        delegate?.flowController(self, didPartiallyLoadProducts: failedIds)
    }

    package func flowView(
        _ view: AdaptyFlowUIView,
        didFinishWebPaymentNavigation product: AdaptyPaywallProduct?,
        error: AdaptyError?
    ) {
        delegate?.flowController(self, didFinishWebPaymentNavigation: product, error: error)
    }
}

#endif
