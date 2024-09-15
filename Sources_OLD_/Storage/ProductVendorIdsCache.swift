//
//  ProductVendorIdsCache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

protocol ProductVendorIdsStorage {
    func setProductVendorIds(_: [String])
    func getProductVendorIds() -> [String]?
}

final class ProductVendorIdsCache {
    private let storage: ProductVendorIdsStorage
    private(set) var allProductVendorIds: [String]?

    init(storage: ProductVendorIdsStorage) {
        self.storage = storage

        allProductVendorIds = storage.getProductVendorIds()
    }

    func setProductVendorIds(_ values: [String]) {
        allProductVendorIds = values
        storage.setProductVendorIds(values)
    }
}
