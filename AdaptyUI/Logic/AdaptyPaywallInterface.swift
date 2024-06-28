//
//  AdaptyPaywallInterface.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import Foundation

package protocol AdaptyPaywallInterface {
    var id: String? { get }
    var locale: String? { get }
    var vendorProductIds: [String] { get }

    func getPaywallProducts(completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>)
    func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration, _ completion: AdaptyErrorCompletion?)
}

extension AdaptyPaywall: AdaptyPaywallInterface {
    package var id: String? { placementId }
    package var locale: String? { remoteConfig?.locale }
    
    package func getPaywallProducts(completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        Adapty.getPaywallProducts(paywall: self, completion)
    }

    package func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration, _ completion: AdaptyErrorCompletion?) {
        Adapty.logShowPaywall(self, viewConfiguration: viewConfiguration, completion)
    }
}
