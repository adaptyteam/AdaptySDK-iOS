//
//  AdaptyPaywallController.swift
//
//
//  Created by Alexey Goncharov on 2023-01-17.
//

import Adapty
import Combine
import UIKit

public class AdaptyPaywallController: UIViewController {
    fileprivate let logId: String

    public let id = UUID()
    public var paywall: AdaptyPaywall { presenter.paywall }
    public var viewConfiguration: AdaptyUI.LocalizedViewConfiguration { presenter.viewConfiguration }

    public weak var delegate: AdaptyPaywallControllerDelegate?

    private var layoutBuilder: LayoutBuilder?
    private let presenter: AdaptyPaywallPresenter
    private var cancellable = Set<AnyCancellable>()
    private let tagResolver: AdaptyTagResolver?

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.logId = logId
        self.delegate = delegate

        let selectedProductIndex: Int

        if let style = try? viewConfiguration.extractDefaultStyle() {
            selectedProductIndex = style.productBlock.mainProductIndex
        } else {
            selectedProductIndex = 0
        }

        presenter = AdaptyPaywallPresenter(logId: logId,
                                           paywall: paywall,
                                           products: products,
                                           selectedProductIndex: selectedProductIndex,
                                           viewConfiguration: viewConfiguration)

        self.tagResolver = tagResolver

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen

        presenter.delegate = self
        presenter.loadProductsIfNeeded()
    }

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

        subscribeForDataChange()
        subscribeForEvents()
        buildInterface()
        subscribeForActions()

        presenter.logShowPaywall()
        log(.verbose, "viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        log(.verbose, "viewDidAppear")
        layoutBuilder?.closeButtonView?.performTransitionIn()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        log(.verbose, "viewDidDisappear")
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutBuilder?.viewDidLayoutSubviews(view)
    }

    private func buildInterface() {
        view.backgroundColor = .white

        let tagConverter: AdaptyUI.CustomTagConverter?

        if let tagResolver = tagResolver {
            tagConverter = { tagResolver.replacement(for: $0) }
        } else {
            tagConverter = nil
        }

        do {
            layoutBuilder = try TemplateLayoutBuilderFabric.createLayoutFromConfiguration(
                presenter.paywall,
                presenter.viewConfiguration,
                products: presenter.products,
                tagConverter: tagConverter
            )

            try layoutBuilder?.buildInterface(on: view)

        } catch {
            handleRenderingError(error)
        }
    }

    private func handleRenderingError(_ error: Error) {
        if let error = error as? AdaptyUIError {
            log(.error, "Rendering Error = \(error)")
            delegate?.paywallController(self, didFailRenderingWith: AdaptyError(error))
        } else {
            log(.error, "Unknown Rendering Error = \(error)")
            let adaptyError = AdaptyError(AdaptyUIError.rendering(error))
            delegate?.paywallController(self, didFailRenderingWith: adaptyError)
        }
    }

    private func handleAction(_ action: AdaptyUI.ButtonAction) {
        switch action {
        case .close:
            log(.verbose, "close tap")
            delegate?.paywallController(self, didPerform: .close)
        case let .openUrl(urlString):
            log(.verbose, "openUrl tap")
            guard let urlString, let url = URL(string: urlString) else { return }
            delegate?.paywallController(self, didPerform: .openURL(url: url))
        case .restore:
            log(.verbose, "restore tap")
            presenter.restorePurchases()
            delegate?.paywallControllerDidStartRestore(self)
        case let .custom(id):
            log(.verbose, "custom (\(id ?? "null") tap")
            guard let id = id else { return }
            delegate?.paywallController(self, didPerform: .custom(id: id))
        case .selectProductId, .purchaseProductId, .purchaseSelectedProduct:
            break
        }
    }

    private func subscribeForDataChange() {
        presenter.$products
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }

                do {
                    try self.layoutBuilder?.productsView?.updateProducts(
                        value,
                        selectedProductId: self.presenter.selectedProductId
                    )
                } catch {
                    self.handleRenderingError(error)
                }

                if let selectedProductId = self.presenter.selectedProductId,
                   let product = value.first(where: { $0.id == selectedProductId }) {
                    self.layoutBuilder?.continueButtonShowIntroCallToAction(product.isEligibleForFreeTrial)
                }
            }
            .store(in: &cancellable)

        presenter.$selectedProductId
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self,
                      let delegate = self.delegate,
                      let product = self.presenter.adaptyProducts?.first(where: { $0.vendorProductId == value }) else {
                    return
                }

                self.updateSelectedProductId(product.vendorProductId)
                delegate.paywallController(self, didSelectProduct: product)
            }
            .store(in: &cancellable)

        presenter.$purchaseInProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.updatePurchaseInProgress(value)
            }
            .store(in: &cancellable)

        presenter.$restoreInProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.updateGlobalLoadingIndicator(restoreInProgress: value, animated: true)
            }
            .store(in: &cancellable)
    }

    private func subscribeForEvents() {
        presenter.onPurchase = { [weak self] result, product in
            self?.handlePurchaseResult(result, product)
        }

        presenter.onRestore = { [weak self] result in
            self?.handleRestoreResult(result)
        }
    }

    private func subscribeForActions() {
        layoutBuilder?.productsView?.onProductSelected = { [weak self] product in
            guard let self = self else { return }

            self.presenter.selectProduct(id: product.id)
            self.layoutBuilder?.continueButtonShowIntroCallToAction(product.isEligibleForFreeTrial)

            if self.presenter.initiatePurchaseOnTap {
                self.presenter.makePurchase()
            }
        }

        layoutBuilder?.addListeners(
            onContinue: { [weak self] in
                guard let self = self else { return }

                self.presenter.makePurchase()

                if let delegate = self.delegate, let product = self.presenter.selectedAdaptyProduct {
                    delegate.paywallController(self, didStartPurchase: product)
                }

            },
            onAction: { [weak self] action in
                guard let action = action else { return }
                self?.handleAction(action)
            }
        )
    }

    private func handlePurchaseResult(_ result: AdaptyResult<AdaptyPurchasedInfo>,
                                      _ product: AdaptyPaywallProduct) {
        switch result {
        case let .success(info):
            delegate?.paywallController(self,
                                        didFinishPurchase: product,
                                        purchasedInfo: info)
        case let .failure(error):
            if error.adaptyErrorCode == .paymentCancelled {
                delegate?.paywallController(self, didCancelPurchase: product)
            } else {
                delegate?.paywallController(self, didFailPurchase: product, error: error)
            }
        }
    }

    private func handleRestoreResult(_ result: AdaptyResult<AdaptyProfile>) {
        switch result {
        case let .success(profile):
            delegate?.paywallController(self, didFinishRestoreWith: profile)
        case let .failure(error):
            delegate?.paywallController(self, didFailRestoreWith: error)
        }
    }

    private func updateSelectedProductId(_ productId: String) {
        layoutBuilder?.productsView?.updateSelectedState(productId)
    }

    private func updatePurchaseInProgress(_ inProgress: Bool) {
        layoutBuilder?.productsView?.isUserInteractionEnabled = !inProgress
        layoutBuilder?.continueButton?.updateInProgress(inProgress)
    }

    private func updateGlobalLoadingIndicator(restoreInProgress: Bool, animated: Bool) {
        if restoreInProgress {
            layoutBuilder?.activityIndicator?.show(animated: animated)
        } else {
            layoutBuilder?.activityIndicator?.hide(animated: animated)
        }
    }
}

extension AdaptyPaywallController: AdaptyPaywallPresenterDelegate {
    func didFailLoadingProducts(with error: AdaptyError) -> Bool {
        delegate?.paywallController(self, didFailLoadingProductsWith: error) ?? false
    }
}

extension AdaptyPaywallController {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
