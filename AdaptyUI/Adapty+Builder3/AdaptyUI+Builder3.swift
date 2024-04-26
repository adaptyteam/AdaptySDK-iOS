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
    public static let BuilderVersion3 = "2"
    
    public static func getViewConfiguration3(
        forPaywall paywall: AdaptyPaywall,
        locale: String,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: [
                "paywall_variation_id": paywall.variationId,
                "paywall_instance_id": paywall.instanceIdentity,
                "locale": locale,
                "ui_sdk_version": AdaptyUI.SDKVersion,
                "builder_version": AdaptyUI.BuilderVersion3,
            ])
        } catch {
            let encodingError = AdaptyUIError.encoding(error)
            completion(.failure(AdaptyError(encodingError)))
            return
        }

        AdaptyUI.getViewConfiguration(data: data) { result in
            completion(result.map { $0.extractLocale(locale) })
        }
    }
    
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
