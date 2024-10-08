//
//  AdaptyPaywallInterface.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import Foundation

@MainActor // TODO: swift 6
package protocol AdaptyPaywallInterface {
    var id: String? { get }
    var locale: String? { get }
    var vendorProductIds: [String] { get }

    func getPaywallProducts() async throws -> [AdaptyPaywallProduct]
    func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) async throws
}

extension AdaptyPaywall: AdaptyPaywallInterface {
    package var id: String? { placementId }
    package var locale: String? { remoteConfig?.locale }
    
    package func getPaywallProducts() async throws -> [AdaptyPaywallProduct] {
        // TODO: swift 6
        return []
//        Adapty.getPaywallProducts(paywall: self, completion)
    }

    package func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) async throws {
        // TODO: swift 6
//        Adapty.logShowPaywall(self, viewConfiguration: viewConfiguration, completion)
    }
}
