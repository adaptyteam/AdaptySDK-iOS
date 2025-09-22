//
//  AdaptyMockPaywall.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import AdaptyUI
import Foundation
import AdaptyUIBuider

struct AdaptyMockPaywall: AdaptyPaywallInterface {
    var placementId: String { "mock" }
    var variationId: String { "mock" }
    var locale: String? { nil }
    var vendorProductIds: [String] { [] }

    func getPaywallProductsWithoutDeterminingOffer() async throws -> [any AdaptyPaywallProductWithoutDeterminingOffer] {
        []
    }

    func getPaywallProducts() async throws -> AdaptyUIGetProductsResult {
        .full(products: [])
    }

    func logShowPaywall(viewConfiguration: AdaptyUIConfiguration) async throws {}
}
