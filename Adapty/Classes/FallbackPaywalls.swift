//
//  FallbackPaywalls.swift
//  Adapty
//
//  Created by Alexey Valiano on 12.08.2022.
//

import Foundation

class FallbackPaywalls: JSONCodable {
    var paywalls: [String: PaywallModel] = [:]
    var products: [ProductModel] = []

    required init?(json: Parameters) throws {
        guard let paywalls = json["data"] as? [Parameters] else {
            return
        }
        do {
            try paywalls.forEach { params in
                if let paywall = try PaywallModel(json: params) {
                    self.paywalls[paywall.id] = paywall
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("FallbackPaywalls - paywalls", paywalls)
        }

        guard let meta = json["meta"] as? Parameters, let products = meta["products"] as? [Parameters] else {
            return
        }

        do {
            try products.forEach { params in
                if let product = try ProductModel(json: params) {
                    self.products.append(product)
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("FallbackPaywalls - products in meta", meta)
        }
    }
}
