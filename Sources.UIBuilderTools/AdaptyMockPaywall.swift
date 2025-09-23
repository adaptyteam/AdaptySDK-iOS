//
//  AdaptyMockPaywall.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import AdaptyUI
import AdaptyUIBuider
import Foundation

struct AdaptyMockPaywall: AdaptyPaywallModel {
    var placementId: String { "mock" }
    var variationId: String { "mock" }
    var locale: String? { nil }
    var vendorProductIds: [String] { [] }
}
