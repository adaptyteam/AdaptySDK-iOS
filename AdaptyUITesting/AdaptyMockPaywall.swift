//
//  AdaptyMockPaywall.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import AdaptyUI
import Foundation

// TODO: swift 6
struct AdaptyMockPaywall: AdaptyPaywallInterface {
    var id: String? { nil }
    var locale: String? { nil }
    var vendorProductIds: [String] { [] }
    
    func getPaywallProducts() async throws -> [AdaptyPaywallProduct] {
        []
    }

    func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) async throws {
    }
}
