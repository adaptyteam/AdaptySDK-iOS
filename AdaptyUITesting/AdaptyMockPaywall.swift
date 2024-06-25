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
    var adaptyProductIds: [String] { [] }
    var vendorProductIds: [String] { [] }

    func getPaywallProducts(completion: @escaping AdaptyResultCompletion<[AdaptyPaywallProduct]>) {
        completion(.success([]))
    }

    func logShowPaywall(viewConfiguration: AdaptyUI.LocalizedViewConfiguration, _ completion: AdaptyErrorCompletion?) {
        completion?(nil)
    }
}
