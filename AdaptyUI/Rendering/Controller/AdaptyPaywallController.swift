//
//  AdaptyPaywallController.swift
//
//
//  Created by Alexey Goncharov on 2023-01-17.
//

#if canImport(UIKit)

import Adapty
import Combine
import SwiftUI
import UIKit

@available(iOS 15.0, *)
public class AdaptyPaywallController: UIViewController {
    public let id = UUID()

    // TODO: consider remove
    public var paywall: AdaptyPaywall { productsViewModel.paywall }
    public var viewConfiguration: AdaptyUI.LocalizedViewConfiguration { productsViewModel.viewConfiguration }

    public weak var delegate: AdaptyPaywallControllerDelegate?

    private var cancellable = Set<AnyCancellable>()

    private let eventsHandler: AdaptyEventsHandler
    private let productsViewModel: AdaptyProductsViewModel
    private let actionsViewModel: AdaptyUIActionsViewModel
    private let sectionsViewModel: AdaptySectionsViewModel
    private let tagResolverViewModel: AdaptyTagResolverViewModel
    private let timerViewModel: AdaptyTimerViewModel

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.delegate = delegate

        eventsHandler = AdaptyEventsHandler(logId: logId)
        tagResolverViewModel = AdaptyTagResolverViewModel(tagResolver: tagResolver)
        actionsViewModel = AdaptyUIActionsViewModel(eventsHandler: eventsHandler)
        sectionsViewModel = AdaptySectionsViewModel(logId: logId)
        productsViewModel = AdaptyProductsViewModel(eventsHandler: eventsHandler,
                                                    paywall: paywall,
                                                    products: products,
                                                    viewConfiguration: viewConfiguration)
        timerViewModel = AdaptyTimerViewModel()

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen

        eventsHandler.didPerformAction = { [weak self] action in
            guard let self else { return }
            self.delegate?.paywallController(self, didPerform: action)
        }
        eventsHandler.didSelectProduct = { [weak self] product in
            guard let self else { return }
            self.delegate?.paywallController(self, didSelectProduct: product)
        }
        eventsHandler.didStartPurchase = { [weak self] product in
            guard let self else { return }
            self.delegate?.paywallController(self, didStartPurchase: product)
        }
        eventsHandler.didFinishPurchase = { [weak self] product, purchasedInfo in
            guard let self else { return }
            self.delegate?.paywallController(self,
                                             didFinishPurchase: product,
                                             purchasedInfo: purchasedInfo)
        }
        eventsHandler.didFailPurchase = { [weak self] product, error in
            guard let self else { return }
            self.delegate?.paywallController(self, didFailPurchase: product, error: error)
        }
        eventsHandler.didCancelPurchase = { [weak self] product in
            guard let self else { return }
            self.delegate?.paywallController(self, didCancelPurchase: product)
        }
        eventsHandler.didStartRestore = { [weak self] in
            guard let self else { return }
            self.delegate?.paywallControllerDidStartRestore(self)
        }
        eventsHandler.didFinishRestore = { [weak self] profile in
            guard let self else { return }
            self.delegate?.paywallController(self, didFinishRestoreWith: profile)
        }
        eventsHandler.didFailRestore = { [weak self] error in
            guard let self else { return }
            self.delegate?.paywallController(self, didFailRestoreWith: error)
        }
        eventsHandler.didFailRendering = { [weak self] error in
            guard let self else { return }
            self.delegate?.paywallController(self, didFailRenderingWith: error)
        }
        eventsHandler.didFailLoadingProducts = { [weak self] error in
            guard let self else { return false }
            guard let delegate = self.delegate else { return true }
            return delegate.paywallController(self, didFailLoadingProductsWith: error)
        }

        productsViewModel.loadProductsIfNeeded()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    deinit {
        eventsHandler.log(.verbose, "deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        eventsHandler.log(.verbose, "viewDidLoad begin")

        view.backgroundColor = .systemBackground

        addSubSwiftUIView(
            AdaptyPaywallRendererView(viewConfiguration: viewConfiguration)
                .withScreenSize(view.bounds.size)
                .environmentObject(productsViewModel)
                .environmentObject(actionsViewModel)
                .environmentObject(sectionsViewModel)
                .environmentObject(tagResolverViewModel)
                .environmentObject(timerViewModel),

            to: view
        )

        eventsHandler.log(.verbose, "viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        eventsHandler.log(.verbose, "viewDidAppear")
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        eventsHandler.log(.verbose, "viewDidDisappear")
    }
}

#endif
