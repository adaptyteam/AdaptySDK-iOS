//
//  Fallback.swift
//  Adapty
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

struct FallbackPaywalls {
    let paywalls: [String: AdaptyPaywall]
    let products: [String: BackendProduct]
    let allProductVendorIds: [String]
}

extension FallbackPaywalls: Decodable {
    enum CodingKeys: String, CodingKey {
        case data
        case meta
        case products
    }

    private struct PaywallContainer: Decodable {
        let paywall: AdaptyPaywall

        enum CodingKeys: String, CodingKey {
            case paywall = "attributes"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let containers = try container.decodeIfPresent([PaywallContainer].self, forKey: .data) {
            paywalls = containers.map { $0.paywall }.map(syncedBundleReceipt: false).asDictionary
        } else {
            paywalls = [:]
        }
        if let subcontainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta),
           let productsArray = try subcontainer.decodeIfPresent([BackendProduct].self, forKey: .products)?.map(syncedBundleReceipt: false) {
            products = productsArray.asDictionary
            allProductVendorIds = productsArray.map { $0.vendorId }
        } else {
            products = [:]
            allProductVendorIds = []
        }
    }

    init(from data: Data) throws {
        self = try Backend.decoder.decode(FallbackPaywalls.self, from: data)
    }
}
