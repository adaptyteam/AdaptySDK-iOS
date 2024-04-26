//
//  AdaptyUI+Builder3.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import UIKit

// MARK: - PB3

extension AdaptyUI {

    public static func paywallController3(
        for paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver? = nil
    ) -> AdaptyBuilder3PaywallController {
        AdaptyBuilder3PaywallController(
            paywall: paywall,
            products: products,
            viewConfiguration: viewConfiguration,
            delegate: delegate,
            tagResolver: tagResolver
        )
    }
}
