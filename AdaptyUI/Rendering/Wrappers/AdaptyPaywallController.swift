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

@available(iOS 15.0, *)
public class AdaptyPaywallController: UIViewController {
    public let id = UUID()
    public let logId: String

    public let paywall: AdaptyPaywall
    public let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    let products: [AdaptyPaywallProduct]?
    let introductoryOffersEligibilities: [String: AdaptyEligibility]?
    let observerModeResolver: AdaptyObserverModeResolver?
    let tagResolver: AdaptyTagResolver?
    let timerResolver: AdaptyTimerResolver?
    let showDebugOverlay: Bool

    public weak var delegate: AdaptyPaywallControllerDelegate?

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        introductoryOffersEligibilities: [String: AdaptyEligibility]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate?,
        observerModeResolver: AdaptyObserverModeResolver?,
        tagResolver: AdaptyTagResolver?,
        timerResolver: AdaptyTimerResolver?,
        showDebugOverlay: Bool
    ) {
        let logId = Log.stamp

        Log.ui.verbose("#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0), observerModeResolver: \(observerModeResolver != nil)")

        // TODO: swift 6
//        if Adapty.Configuration.observerMode && observerModeResolver == nil {
//            Log.ui.warn("In order to handle purchases in Observer Mode enabled, provide the observerModeResolver!")
//        } else if !Adapty.Configuration.observerMode && observerModeResolver != nil {
//            Log.ui.warn("You should not pass observerModeResolver if you're using Adapty in Full Mode")
//        }
        
        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
        self.products = products
        self.introductoryOffersEligibilities = introductoryOffersEligibilities
        self.tagResolver = tagResolver
        self.timerResolver = timerResolver
        self.delegate = delegate
        self.observerModeResolver = observerModeResolver
        self.showDebugOverlay = showDebugOverlay

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
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

        addSubSwiftUIView(
            AdaptyPaywallView_Internal(
                logId: logId,
                paywall: paywall,
                products: products,
                introductoryOffersEligibilities: introductoryOffersEligibilities,
                configuration: viewConfiguration,
                observerModeResolver: observerModeResolver,
                tagResolver: tagResolver,
                timerResolver: timerResolver ?? AdaptyUIDefaultTimerResolver(),
                showDebugOverlay: showDebugOverlay,
                didPerformAction: { [weak self] action in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didPerform: action)
                },
                didSelectProduct: { [weak self] underlying in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didSelectProduct: underlying)
                },
                didStartPurchase: { [weak self] underlying in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didStartPurchase: underlying)
                },
                didFinishPurchase: { [weak self] underlying, purchasedInfo in
                    guard let self else { return }
                    self.delegate?.paywallController(self,
                                                     didFinishPurchase: underlying,
                                                     purchasedInfo: purchasedInfo)
                },
                didFailPurchase: { [weak self] underlying, error in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didFailPurchase: underlying, error: error)
                },
                didCancelPurchase: { [weak self] underlying in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didCancelPurchase: underlying)
                },
                didStartRestore: { [weak self] in
                    guard let self else { return }
                    self.delegate?.paywallControllerDidStartRestore(self)
                },
                didFinishRestore: { [weak self] profile in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didFinishRestoreWith: profile)
                },
                didFailRestore: { [weak self] error in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didFailRestoreWith: error)
                },
                didFailRendering: { [weak self] error in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didFailRenderingWith: error)
                },
                didFailLoadingProducts: { [weak self] error in
                    guard let self else { return false }
                    guard let delegate = self.delegate else { return true }
                    return delegate.paywallController(self, didFailLoadingProductsWith: error)
                }
            ),
            to: view
        )

        Log.ui.verbose("#\(logId)# viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Log.ui.verbose("#\(logId)# viewDidAppear")
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Log.ui.verbose("#\(logId)# viewDidDisappear")
    }
}

#endif
