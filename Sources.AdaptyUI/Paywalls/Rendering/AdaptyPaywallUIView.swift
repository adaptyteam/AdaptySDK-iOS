//
//  AdaptyPaywallUIView.swift
//  Adapty
//
//  Created by Alexey Goncharov on 8/6/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import SwiftUI
import UIKit

package final class AdaptyPaywallUIView: UIView {
    let id: String
    let configuration: AdaptyUI.PaywallConfiguration
    let logId: String
    
    private let showDebugOverlay: Bool

    package init(
        configuration: AdaptyUI.PaywallConfiguration,
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

    weak var delegate: AdaptyPaywallViewDelegate?

    package func configure(delegate: AdaptyPaywallViewDelegate) {
        Log.ui.verbose("V #\(logId)# view configure")

        self.delegate = delegate

        configuration.eventsHandler.didAppear = { [weak self] in
            guard let self else { return }
            self.delegate?.paywallViewDidAppear(self)
        }

        configuration.eventsHandler.didDisappear = { [weak self] in
            guard let self else { return }
            self.delegate?.paywallViewDidDisappear(self)
        }

        configuration.eventsHandler.didPerformAction = { [weak self] action in
            guard let self else { return }
            self.delegate?.paywallView(self, didPerform: action)
        }

        configuration.eventsHandler.didSelectProduct = { [weak self] underlying in
            guard let self else { return }
            self.delegate?.paywallView(self, didSelectProduct: underlying)
        }

        configuration.eventsHandler.didStartPurchase = { [weak self] underlying in
            guard let self else { return }
            self.delegate?.paywallView(self, didStartPurchase: underlying)
        }

        configuration.eventsHandler.didFinishPurchase = { [weak self] underlying, purchaseResult in
            guard let self else { return }
            self.delegate?.paywallView(
                self,
                didFinishPurchase: underlying,
                purchaseResult: purchaseResult
            )
        }

        configuration.eventsHandler.didFailPurchase = { [weak self] underlying, error in
            guard let self else { return }
            self.delegate?.paywallView(self, didFailPurchase: underlying, error: error)
        }

        configuration.eventsHandler.didStartRestore = { [weak self] in
            guard let self else { return }
            self.delegate?.paywallViewDidStartRestore(self)
        }

        configuration.eventsHandler.didFinishRestore = { [weak self] profile in
            guard let self else { return }
            self.delegate?.paywallView(self, didFinishRestoreWith: profile)
        }

        configuration.eventsHandler.didFailRestore = { [weak self] error in
            guard let self else { return }
            self.delegate?.paywallView(self, didFailRestoreWith: error)
        }

        configuration.eventsHandler.didFailRendering = { [weak self] error in
            guard let self else { return }
            self.delegate?.paywallView(self, didFailRenderingWith: error)
        }

        configuration.eventsHandler.didFailLoadingProducts = { [weak self] error in
            guard let self else { return false }
            guard let delegate = self.delegate else { return true }
            return delegate.paywallView(self, didFailLoadingProductsWith: error)
        }

        configuration.eventsHandler.didPartiallyLoadProducts = { [weak self] failedIds in
            guard let self else { return }
            self.delegate?.paywallView(self, didPartiallyLoadProducts: failedIds)
        }

        configuration.eventsHandler.didFinishWebPaymentNavigation = { [weak self] product, error in
            guard let self else { return }

            self.delegate?.paywallView(
                self,
                didFinishWebPaymentNavigation: product,
                error: error
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
                showDebugOverlay: showDebugOverlay
            )
            .environmentObjects(
                stateViewModel: configuration.stateViewModel,
                paywallViewModel: configuration.paywallViewModel,
                productsViewModel: configuration.productsViewModel,
                sectionsViewModel: configuration.sectionsViewModel,
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
