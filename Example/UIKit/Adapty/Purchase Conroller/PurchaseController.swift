//
//  PurchaseController.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Combine
import UIKit

class PurchaseController: UIViewController {
    private var cancellable = Set<AnyCancellable>()
    var presenter: PurchasePresenter!

    @IBOutlet var headlineLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var variantsContainer: UIStackView!
    @IBOutlet var restoreButton: UIButton!
    @IBOutlet var progressView: UIView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    private var config: PurchaseConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface(presenter.paywall)

        presenter.$paywall
            .sink(receiveValue: { [weak self] paywall in
                self?.configureInterface(paywall)
            })
            .store(in: &cancellable)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.logShowPaywall()
    }

    private func configureInterface(_ paywall: PaywallModel) {
        config = paywall.extractPurchaseConfiguration()
        configureTheme()
        configureVariants(paywall)
    }

    private func configureTheme() {
        headlineLabel.textColor = config.accentColor
        subtitleLabel.textColor = config.accentColor
        restoreButton.setTitleColor(config.accentColor, for: .normal)

        view.backgroundColor = config.backgroundColor

        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
    }

    private func configureVariants(_ paywall: PaywallModel) {
        for v in variantsContainer.arrangedSubviews {
            variantsContainer.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        for product in paywall.products {
            let productView: IPurchaseButton = presenter.isHorizontalLayout ? PurchaseTallButton.instantiate() : PurchaseWideButton.instantiate()
            productView.update(product: product, config: config) { [weak self] in
                self?.purchaseProductPressed(product)
            }

            variantsContainer.addArrangedSubview(productView)
        }
    }

    private func setInProgress(_ inProgress: Bool) {
        progressView.isHidden = !inProgress
        if inProgress {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    private func purchaseProductPressed(_ product: ProductModel) {
        setInProgress(true)
        presenter.makePurchase(product, completion: { [weak self] error in
            self?.setInProgress(false)

            if let error = error {
                if let adaptyError = error as? AdaptyError, adaptyError.adaptyErrorCode == AdaptyError.AdaptyErrorCode.paymentCancelled {
                    // user cancelled
                } else {
                    self?.showAlert(for: error)
                }
            } else {
                self?.dismiss(animated: true)
            }
        })
    }

    @IBAction func restoreButtonPressed(_ sender: Any) {
        setInProgress(true)

        presenter.restorePurchases { [weak self] error in
            self?.setInProgress(false)

            if let error = error {
                self?.showAlert(for: error)
            } else {
                // check if user is premium
            }
        }
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PurchaseController {
    private static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    static func instantiateVertical() -> PurchaseController {
        storyboard.instantiateViewController(withIdentifier: "PurchaseVerticalController") as! PurchaseController
    }

    static func instantiateHorizontal() -> PurchaseController {
        storyboard.instantiateViewController(withIdentifier: "PurchaseHorizontalController") as! PurchaseController
    }
}
