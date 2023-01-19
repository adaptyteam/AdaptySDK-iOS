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
    let version: Int
}

extension FallbackPaywalls: Decodable {
    enum CodingKeys: String, CodingKey {
        case data
        case meta
        case products
        case version
    }

    private struct PaywallContainer: Decodable {
        let paywall: AdaptyPaywall

        enum CodingKeys: String, CodingKey {
            case paywall = "attributes"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subcontainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta)

        if let subcontainer = subcontainer,
           let v = try subcontainer.decodeIfPresent(Int.self, forKey: .version) {
            version = v
        } else {
            version = 0
        }

        if let containers = try container.decodeIfPresent([PaywallContainer].self, forKey: .data) {
            paywalls = containers.map { $0.paywall }.map(syncedBundleReceipt: false).asDictionary
        } else {
            paywalls = [:]
        }

        if let subcontainer = subcontainer,
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
