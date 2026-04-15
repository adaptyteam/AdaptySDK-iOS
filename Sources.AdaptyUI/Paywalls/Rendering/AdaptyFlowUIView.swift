//
//  AdaptyFlowUIView.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import SwiftUI
import UIKit

package final class AdaptyFlowUIView: UIView {
    let id: String
    let configuration: AdaptyUI.FlowConfiguration
    let logId: String

    private let showDebugOverlay: Bool

    package init(
        configuration: AdaptyUI.FlowConfiguration,
        showDebugOverlay: Bool = false,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.configuration = configuration
        self.showDebugOverlay = showDebugOverlay
        logId = configuration.eventsHandler.logId

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.ui.verbose("#\(logId)# view deinit")
    }

    weak var delegate: AdaptyFlowViewDelegate?

    package func configure(delegate: AdaptyFlowViewDelegate) {
        Log.ui.verbose("V #\(logId)# view configure")

        self.delegate = delegate

        configuration.eventsHandler.didAppear = { [weak self] in
            guard let self else { return }
            self.delegate?.flowViewDidAppear(self)
        }

        configuration.eventsHandler.didDisappear = { [weak self] in
            guard let self else { return }
            self.delegate?.flowViewDidDisappear(self)
        }

        configuration.eventsHandler.didPerformAction = { [weak self] action in
            guard let self else { return }
            self.delegate?.flowView(self, didPerform: action)
        }

        configuration.eventsHandler.didSelectProduct = { [weak self] underlying in
            guard let self else { return }
            self.delegate?.flowView(self, didSelectProduct: underlying)
        }

        configuration.eventsHandler.didStartPurchase = { [weak self] underlying in
            guard let self else { return }
            self.delegate?.flowView(self, didStartPurchase: underlying)
        }

        configuration.eventsHandler.didFinishPurchase = { [weak self] underlying, purchaseResult in
            guard let self else { return }
            self.delegate?.flowView(
                self,
                didFinishPurchase: underlying,
                purchaseResult: purchaseResult
            )
        }

        configuration.eventsHandler.didFailPurchase = { [weak self] underlying, error in
            guard let self else { return }
            self.delegate?.flowView(self, didFailPurchase: underlying, error: error)
        }

        configuration.eventsHandler.didStartRestore = { [weak self] in
            guard let self else { return }
            self.delegate?.flowViewDidStartRestore(self)
        }

        configuration.eventsHandler.didFinishRestore = { [weak self] profile in
            guard let self else { return }
            self.delegate?.flowView(self, didFinishRestoreWith: profile)
        }

        configuration.eventsHandler.didFailRestore = { [weak self] error in
            guard let self else { return }
            self.delegate?.flowView(self, didFailRestoreWith: error)
        }

        configuration.eventsHandler.didFailRendering = { [weak self] error in
            guard let self else { return }
            self.delegate?.flowView(self, didFailRenderingWith: error)
        }

        configuration.eventsHandler.didFailLoadingProducts = { [weak self] error in
            guard let self else { return false }
            guard let delegate = self.delegate else { return true }
            return delegate.flowView(self, didFailLoadingProductsWith: error)
        }

        configuration.eventsHandler.didPartiallyLoadProducts = { [weak self] failedIds in
            guard let self else { return }
            self.delegate?.flowView(self, didPartiallyLoadProducts: failedIds)
        }

        configuration.eventsHandler.didFinishWebPaymentNavigation = { [weak self] product, error in
            guard let self else { return }

            self.delegate?.flowView(
                self,
                didFinishWebPaymentNavigation: product,
                error: error
            )
        }

        configuration.eventsHandler.didReceiveAnalyticEvent = { [weak self] name, params in
            guard let self else { return }

            self.delegate?.flowView(
                self,
                didReceiveAnalyticEvent: name,
                params: params
            )
        }
    }

    package func layout(in parentView: UIView, parentVC: UIViewController) {
        Log.ui.verbose("V #\(logId)# view layout(in:parentVC:)")

        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(self)

        parentView.addConstraints([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            topAnchor.constraint(equalTo: parentView.topAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])

        parentVC.addSubSwiftUIView(
            AdaptyUIPaywallView_Internal(
                showDebugOverlay: showDebugOverlay,
                displayMissingTags: false
            )
            .environmentObjects(
                stateViewModel: configuration.stateViewModel,
                flowViewModel: configuration.flowViewModel,
                productsViewModel: configuration.productsViewModel,
                tagResolverViewModel: configuration.tagResolverViewModel,
                timerViewModel: configuration.timerViewModel,
                screensViewModel: configuration.screensViewModel,
                assetsViewModel: configuration.assetsViewModel
            ),
            to: self
        )
    }

    package func reportOnAppear() {
        Log.ui.verbose("#\(logId)# view reportOnAppear")

        configuration.reportOnAppear()
    }

    package func reportOnDisappear() {
        Log.ui.verbose("#\(logId)# view reportOnDisappear")

        configuration.reportOnDisappear()
    }
}

#endif
