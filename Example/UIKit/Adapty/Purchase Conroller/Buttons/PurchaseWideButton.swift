//
//  PurchaseWideButton.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 17.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import UIKit

class PurchaseWideButton: UIView, IPurchaseButton {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!

    private var onAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 12.0
    }

    func update(product: AdaptyPaywallProduct, config: PurchaseConfiguration, action: @escaping () -> Void) {
        defer {
            onAction = action

            titleLabel.textColor = config.backgroundColor
            subtitleLabel.textColor = config.backgroundColor
            backgroundColor = config.accentColor
        }

        guard let price = product.localizedPrice, let period = product.subscriptionPeriod else {
            titleLabel.text = product.vendorProductId
            subtitleLabel.text = " "
            return
        }

        switch (period.unit, period.numberOfUnits) {
        case (.day, 7), (.week, 1):
            titleLabel.text = "Weekly Subscription for \(price)"
        case (.month, 1):
            titleLabel.text = "Monthly Subscription for \(price)"
        case (.month, 3):
            titleLabel.text = "3 Months Subscription for \(price)"
        case (.year, 1):
            titleLabel.text = "Annual Subscription for \(price)"
        default:
            titleLabel.text = "Strange Subscription for \(price)"
        }

        if let discount = product.introductoryDiscount {
            if product.introductoryOfferEligibility != .eligible {
                subtitleLabel.text = "Not Eligble for Discount"
            } else {
                switch (discount.subscriptionPeriod.unit, discount.subscriptionPeriod.numberOfUnits) {
                case (.day, 3):
                    subtitleLabel.text = "Three Days (\(discount.paymentMode.title))"
                case (.day, 7), (.week, 1):
                    subtitleLabel.text = "One Week (\(discount.paymentMode.title))"
                case (.month, 1):
                    subtitleLabel.text = "One Month (\(discount.paymentMode.title))"
                case (.year, 1):
                    subtitleLabel.text = "One Year (\(discount.paymentMode.title))"
                default:
                    subtitleLabel.text = "Strange Another (\(discount.paymentMode.title))"
                }
            }
        } else {
            subtitleLabel.text = "Discount Not Found"
        }
    }

    @IBAction func buttonPressed() {
        onAction?()
    }
}

extension PurchaseWideButton {
    static func instantiate() -> PurchaseWideButton {
        Bundle.main.loadNibNamed("PurchaseWideButton", owner: nil)![0] as! PurchaseWideButton
    }
}
