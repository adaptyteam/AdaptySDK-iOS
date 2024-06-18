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
    let tagResolver: AdaptyTagResolver?

    public weak var delegate: AdaptyPaywallControllerDelegate?

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate?,
        tagResolver: AdaptyTagResolver?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.logId = logId
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
        self.products = products
        self.tagResolver = tagResolver
        self.delegate = delegate

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
        log(.verbose, "deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        log(.verbose, "viewDidLoad begin")

        view.backgroundColor = .systemBackground

        addSubSwiftUIView(
            AdaptyPaywallView(
                logId: logId,
                paywall: paywall,
                products: products,
                configuration: viewConfiguration,
                tagResolver: tagResolver,
                didPerformAction: { [weak self] action in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didPerform: action)
                },
                didSelectProduct: { [weak self] product in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didSelectProduct: product)
                },
                didStartPurchase: { [weak self] product in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didStartPurchase: product)
                },
                didFinishPurchase: { [weak self] product, purchasedInfo in
                    guard let self else { return }
                    self.delegate?.paywallController(self,
                                                     didFinishPurchase: product,
                                                     purchasedInfo: purchasedInfo)
                },
                didFailPurchase: { [weak self] product, error in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didFailPurchase: product, error: error)
                },
                didCancelPurchase: { [weak self] product in
                    guard let self else { return }
                    self.delegate?.paywallController(self, didCancelPurchase: product)
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

        log(.verbose, "viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        log(.verbose, "viewDidAppear")
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        log(.verbose, "viewDidDisappear")
    }
    
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}

#endif
