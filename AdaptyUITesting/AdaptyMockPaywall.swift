//
//  AdaptyMockPaywall.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import AdaptyUI
import Foundation

struct AdaptyMockPaywall: AdaptyPaywallInterface {
    var id: String? { nil }
    var locale: String? { nil }
    var vendorProductIds: [String] { [] }

    func getPaywallProductsWithoutDeterminingOffer() async throws -> [any AdaptyPaywallProductWithoutDeterminingOffer] {
        []
    }

    func getPaywallProducts() async throws -> AdaptyUIGetProductsResult {
        .full(products: [])
    }

    func logShowPaywall(viewConfiguration: AdaptyViewConfiguration) async throws {}
}
