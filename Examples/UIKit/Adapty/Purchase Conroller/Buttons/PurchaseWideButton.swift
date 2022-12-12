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
    @IBOutlet private var introLabel: UILabel!
    @IBOutlet private var promoLabel: UILabel!

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
            introLabel.textColor = config.backgroundColor
            promoLabel.textColor = config.backgroundColor

            backgroundColor = config.accentColor
        }

        titleLabel.text = "\(product.vendorProductId)"
        subtitleLabel.text =
            """
            Period: \(product.localizedSubscriptionPeriod ?? "nil")
            Price: \(product.localizedPrice ?? "nil")
            """

        var introText = "Intro: \(product.introductoryOfferEligibility)"

        if let discount = product.introductoryDiscount {
            introText += "\nMode: \(discount.paymentMode.title)"
            introText += "\nPrice \(discount.localizedPrice ?? "nil")"
        }

        introLabel.text = introText

        if !product.discounts.isEmpty {
            var promoText = "Promo: \(product.promotionalOfferId ?? "nil")"

            for discount in product.discounts {
                promoText += "\n\(discount.paymentMode.title) for \(discount.localizedPrice ?? "nil"), \(discount.localizedNumberOfPeriods ?? "nil")"
            }

            promoLabel.text = promoText
        } else {
            promoLabel.text = "Promo: \(product.promotionalOfferId ?? "nil")"
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
